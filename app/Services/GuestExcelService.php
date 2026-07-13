<?php

namespace App\Services;

use App\Models\Guest;
use App\Models\User;
use Illuminate\Support\Str;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Throwable;

class GuestExcelService
{
    /**
     * @var list<string>
     */
    public const TEMPLATE_HEADERS = [
        'No',
        'Nama Lengkap',
        'Telepon',
        'Email',
        'Nomor Meja',
        'Status RSVP',
        'Catatan',
    ];

    public function downloadTemplate(): BinaryFileResponse
    {
        $spreadsheet = new Spreadsheet;
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Daftar Tamu');
        $sheet->fromArray(self::TEMPLATE_HEADERS, null, 'A1');
        $sheet->getStyle('A1:G1')->getFont()->setBold(true);
        $sheet->fromArray([
            1,
            'Bapak Contoh Nama',
            '081234567890',
            'contoh@email.com',
            '12',
            'menunggu',
            'Contoh baris data. Hapus sebelum upload.',
        ], null, 'A2');

        foreach (range('A', 'G') as $column) {
            $sheet->getColumnDimension($column)->setAutoSize(true);
        }

        $guideSheet = $spreadsheet->createSheet();
        $guideSheet->setTitle('Petunjuk');
        $guideSheet->fromArray([
            ['Kolom', 'Wajib', 'Keterangan'],
            ['No', 'Tidak', 'Nomor urut tampilan. Jika kosong, diisi otomatis berurutan.'],
            ['Nama Lengkap', 'Ya', 'Nama tamu undangan.'],
            ['Telepon', 'Tidak', 'Nomor telepon atau WhatsApp.'],
            ['Email', 'Tidak', 'Alamat email tamu.'],
            ['Nomor Meja', 'Tidak', 'Nomor meja duduk tamu.'],
            ['Status RSVP', 'Tidak', 'Isi kode atau label RSVP (default: menunggu).'],
            ['Catatan', 'Tidak', 'Catatan tambahan.'],
            [],
            ['Kode RSVP', 'Label'],
            ...collect(Guest::$rsvpOptions)
                ->map(fn (string $label, string $key): array => [$key, $label])
                ->values()
                ->all(),
        ], null, 'A1');
        $guideSheet->getStyle('A1:C1')->getFont()->setBold(true);
        $guideSheet->getStyle('A11:B11')->getFont()->setBold(true);

        foreach (range('A', 'C') as $column) {
            $guideSheet->getColumnDimension($column)->setAutoSize(true);
        }

        $spreadsheet->setActiveSheetIndex(0);

        $tempPath = tempnam(sys_get_temp_dir(), 'guest_template_');
        $filePath = $tempPath.'.xlsx';
        rename($tempPath, $filePath);

        (new Xlsx($spreadsheet))->save($filePath);

        return response()->download(
            $filePath,
            'template-daftar-tamu.xlsx',
            ['Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
        )->deleteFileAfterSend();
    }

    /**
     * @return array{imported: int, skipped: int, errors: list<string>}
     */
    public function import(User $user, string $filePath): array
    {
        $spreadsheet = IOFactory::load($filePath);
        $sheet = $spreadsheet->getSheetByName('Daftar Tamu') ?? $spreadsheet->getActiveSheet();
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
        $nextNumber = ((int) $user->guests()->max('no')) + 1;

        foreach ($rows as $rowNumber => $row) {
            $lineNumber = is_int($rowNumber) ? $rowNumber : (int) $rowNumber;

            try {
                $payload = $this->mapRowToPayload($row, $columnMap, $nextNumber);

                if ($payload === null) {
                    continue;
                }

                if ($this->isExampleRow($payload)) {
                    $skipped++;

                    continue;
                }

                $user->guests()->create($payload);
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
            'phone' => ['telepon', 'phone', 'whatsapp', 'no hp', 'no. hp'],
            'email' => ['email', 'e-mail', 'alamat email'],
            'table_number' => ['nomor meja', 'meja', 'table', 'table number', 'no meja'],
            'rsvp_status' => ['status rsvp', 'rsvp', 'rsvp status', 'status'],
            'catatan' => ['catatan', 'notes', 'keterangan'],
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
     *     no: int,
     *     name: string,
     *     phone: ?string,
     *     email: ?string,
     *     table_number: ?string,
     *     rsvp_status: string,
     *     catatan: ?string
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

        $email = ($values['email'] ?? '') !== '' ? $values['email'] : null;

        if ($email !== null && ! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException("Email \"{$email}\" tidak valid.");
        }

        $no = $values['no'] ?? '';

        return [
            'no' => $no !== '' && is_numeric($no) ? (int) $no : $fallbackNumber,
            'name' => $values['name'],
            'phone' => ($values['phone'] ?? '') !== '' ? $values['phone'] : null,
            'email' => $email,
            'table_number' => ($values['table_number'] ?? '') !== '' ? $values['table_number'] : null,
            'rsvp_status' => $this->normalizeRsvpStatus($values['rsvp_status'] ?? null),
            'catatan' => ($values['catatan'] ?? '') !== '' ? $values['catatan'] : null,
        ];
    }

    /**
     * @param  array{
     *     no: int,
     *     name: string,
     *     phone: ?string,
     *     email: ?string,
     *     table_number: ?string,
     *     rsvp_status: string,
     *     catatan: ?string
     * }  $payload
     */
    private function isExampleRow(array $payload): bool
    {
        return Str::lower($payload['name']) === 'bapak contoh nama'
            || Str::contains(Str::lower((string) $payload['catatan']), 'contoh baris data');
    }

    private function normalizeRsvpStatus(?string $value): string
    {
        $value = Str::of($value ?? '')->lower()->trim()->replace(' ', '_')->toString();

        if ($value === '') {
            return 'menunggu';
        }

        if (isset(Guest::$rsvpOptions[$value])) {
            return $value;
        }

        foreach (Guest::$rsvpOptions as $key => $label) {
            if (Str::lower($label) === Str::of($value)->replace('_', ' ')->toString()) {
                return $key;
            }
        }

        throw new \InvalidArgumentException("Status RSVP \"{$value}\" tidak valid.");
    }
}
