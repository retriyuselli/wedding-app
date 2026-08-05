<?php

namespace App\Services;

use App\Models\FamilyMember;
use App\Models\User;
use App\Support\ExcelSupport;
use Illuminate\Support\Str;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Throwable;

class FamilyMemberExcelService
{
    /**
     * @var list<string>
     */
    public const TEMPLATE_HEADERS = [
        'No',
        'Nama Lengkap',
        'Peran / Hubungan',
        'Telepon',
        'Status RSVP',
    ];

    public function downloadTemplate(): BinaryFileResponse
    {
        ExcelSupport::ensureZipAvailable();

        $spreadsheet = new Spreadsheet;
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Anggota Keluarga');
        $sheet->fromArray(self::TEMPLATE_HEADERS, null, 'A1');
        $sheet->getStyle('A1:E1')->getFont()->setBold(true);
        $sheet->fromArray([
            1,
            'Bapak Contoh Nama',
            'Ayah',
            '081234567890',
            'menunggu',
        ], null, 'A2');
        $sheet->setCellValue('F2', 'Contoh baris data. Hapus sebelum upload.');

        foreach (range('A', 'F') as $column) {
            $sheet->getColumnDimension($column)->setAutoSize(true);
        }

        $guideSheet = $spreadsheet->createSheet();
        $guideSheet->setTitle('Petunjuk');
        $guideSheet->fromArray([
            ['Kolom', 'Wajib', 'Keterangan'],
            ['No', 'Tidak', 'Nomor urut tampil. Kosongkan untuk auto-number.'],
            ['Nama Lengkap', 'Ya', 'Nama anggota keluarga.'],
            ['Peran / Hubungan', 'Tidak', 'Contoh: Ayah, Ibu, Kakak, Adik.'],
            ['Telepon', 'Tidak', 'Nomor telepon atau WhatsApp.'],
            ['Status RSVP', 'Tidak', 'Isi kode atau label RSVP (default: menunggu).'],
            [],
            ['Kode RSVP', 'Label'],
            ...collect(FamilyMember::$rsvpOptions)
                ->map(fn (string $label, string $key): array => [$key, $label])
                ->values()
                ->all(),
        ], null, 'A1');
        $guideSheet->getStyle('A1:C1')->getFont()->setBold(true);
        $guideSheet->getStyle('A9:B9')->getFont()->setBold(true);

        foreach (range('A', 'C') as $column) {
            $guideSheet->getColumnDimension($column)->setAutoSize(true);
        }

        $spreadsheet->setActiveSheetIndex(0);

        $filePath = ExcelSupport::makeTemporaryXlsxPath('family_member_template_');
        (new Xlsx($spreadsheet))->save($filePath);

        return response()->download(
            $filePath,
            'template-anggota-keluarga.xlsx',
            ['Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
        )->deleteFileAfterSend();
    }

    /**
     * @return array{imported: int, skipped: int, errors: list<string>}
     */
    public function import(User $user, string $filePath): array
    {
        ExcelSupport::ensureZipAvailable();

        $spreadsheet = IOFactory::load($filePath);
        $sheet = $spreadsheet->getSheetByName('Anggota Keluarga') ?? $spreadsheet->getActiveSheet();
        $rows = $sheet->toArray(null, true, true, true);

        if ($rows === []) {
            return [
                'imported' => 0,
                'skipped' => 0,
                'errors' => ['File Excel kosong.'],
            ];
        }

        $headerRow = array_shift($rows);
        $columnMap = $this->resolveColumnMap($headerRow);

        if (! in_array('name', $columnMap, true)) {
            return [
                'imported' => 0,
                'skipped' => 0,
                'errors' => ['Kolom "Nama Lengkap" tidak ditemukan. Gunakan template Excel yang disediakan.'],
            ];
        }

        $imported = 0;
        $skipped = 0;
        $errors = [];
        $nextNumber = ((int) $user->familyMembers()->max('no')) + 1;

        foreach ($rows as $rowNumber => $row) {
            $lineNumber = is_int($rowNumber) ? $rowNumber : (int) $rowNumber;

            try {
                $payload = $this->mapRowToPayload($row, $columnMap, $nextNumber);

                if ($payload === null) {
                    continue;
                }

                if ($this->isExampleRow($payload, $row)) {
                    $skipped++;

                    continue;
                }

                $user->familyMembers()->create($payload);
                $imported++;

                if ($payload['no'] !== null) {
                    $nextNumber = max($nextNumber, ((int) $payload['no']) + 1);
                } else {
                    $nextNumber++;
                }
            } catch (Throwable $exception) {
                $skipped++;
                $errors[] = "Baris {$lineNumber}: {$exception->getMessage()}";
            }
        }

        return compact('imported', 'skipped', 'errors');
    }

    /**
     * @param  array<int|string, mixed>  $headerRow
     * @return array<int|string, string>
     */
    private function resolveColumnMap(array $headerRow): array
    {
        $aliases = [
            'no' => ['no', 'nomor', 'nomor urut'],
            'name' => ['nama lengkap', 'nama', 'name'],
            'role' => ['peran / hubungan', 'peran', 'hubungan', 'role'],
            'phone' => ['telepon', 'phone', 'whatsapp', 'no hp', 'no. hp'],
            'rsvp_status' => ['status rsvp', 'rsvp', 'rsvp status', 'status'],
        ];

        $columnMap = [];

        foreach ($headerRow as $columnKey => $headerValue) {
            $normalizedHeader = Str::of((string) $headerValue)->lower()->trim()->toString();

            if ($normalizedHeader === '') {
                continue;
            }

            foreach ($aliases as $field => $options) {
                if (in_array($normalizedHeader, $options, true)) {
                    $columnMap[$columnKey] = $field;
                }
            }
        }

        return $columnMap;
    }

    /**
     * @param  array<int|string, mixed>  $row
     * @param  array<int|string, string>  $columnMap
     * @return array{
     *     no: ?int,
     *     name: string,
     *     role: ?string,
     *     phone: ?string,
     *     rsvp_status: string
     * }|null
     */
    private function mapRowToPayload(array $row, array $columnMap, int $fallbackNumber): ?array
    {
        $values = [];

        foreach ($columnMap as $columnKey => $field) {
            $values[$field] = trim((string) ($row[$columnKey] ?? ''));
        }

        if (($values['name'] ?? '') === '') {
            return null;
        }

        $no = $values['no'] ?? '';

        return [
            'no' => $no !== '' && is_numeric($no) ? (int) $no : $fallbackNumber,
            'name' => $values['name'],
            'role' => ($values['role'] ?? '') !== '' ? $values['role'] : null,
            'phone' => ($values['phone'] ?? '') !== '' ? $values['phone'] : null,
            'rsvp_status' => $this->normalizeRsvpStatus($values['rsvp_status'] ?? null),
        ];
    }

    /**
     * @param  array{
     *     no: ?int,
     *     name: string,
     *     role: ?string,
     *     phone: ?string,
     *     rsvp_status: string
     * }  $payload
     * @param  array<int|string, mixed>  $row
     */
    private function isExampleRow(array $payload, array $row): bool
    {
        $extraNote = trim((string) ($row['F'] ?? ''));

        return Str::lower($payload['name']) === 'bapak contoh nama'
            || Str::contains(Str::lower($extraNote), 'contoh baris data');
    }

    private function normalizeRsvpStatus(?string $value): string
    {
        $value = Str::of($value ?? '')->lower()->trim()->replace(' ', '_')->toString();

        if ($value === '') {
            return 'menunggu';
        }

        if (isset(FamilyMember::$rsvpOptions[$value])) {
            return $value;
        }

        foreach (FamilyMember::$rsvpOptions as $key => $label) {
            if (Str::lower($label) === Str::of($value)->replace('_', ' ')->toString()) {
                return $key;
            }
        }

        throw new \InvalidArgumentException("Status RSVP \"{$value}\" tidak valid.");
    }
}
