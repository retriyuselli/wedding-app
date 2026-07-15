<?php

namespace App\Services;

use App\Models\User;
use App\Models\VipGuest;
use App\Support\ExcelSupport;
use Illuminate\Support\Str;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Throwable;

class VipGuestExcelService
{
    /**
     * @var list<string>
     */
    public const TEMPLATE_HEADERS = [
        'No',
        'Nama Lengkap',
        'Jabatan',
        'Instansi',
        'Telepon',
        'Kategori',
        'Status RSVP',
        'Catatan',
    ];

    public function downloadTemplate(): BinaryFileResponse
    {
        ExcelSupport::ensureZipAvailable();

        $spreadsheet = new Spreadsheet;
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle('Tamu VIP');
        $sheet->fromArray(self::TEMPLATE_HEADERS, null, 'A1');
        $sheet->getStyle('A1:H1')->getFont()->setBold(true);
        $sheet->fromArray([
            1,
            'Bapak Contoh Nama',
            'Direktur',
            'Pemerintah Daerah',
            '081234567890',
            'vip',
            'menunggu',
            'Contoh baris data. Hapus sebelum upload.',
        ], null, 'A2');

        foreach (range('A', 'H') as $column) {
            $sheet->getColumnDimension($column)->setAutoSize(true);
        }

        $guideSheet = $spreadsheet->createSheet();
        $guideSheet->setTitle('Petunjuk');
        $guideSheet->fromArray([
            ['Kolom', 'Wajib', 'Keterangan'],
            ['No', 'Tidak', 'Nomor urut tampil. Kosongkan untuk auto-number.'],
            ['Nama Lengkap', 'Ya', 'Nama tamu VIP.'],
            ['Jabatan', 'Tidak', 'Jabatan tamu.'],
            ['Instansi', 'Tidak', 'Instansi atau organisasi.'],
            ['Telepon', 'Tidak', 'Nomor telepon atau WhatsApp.'],
            ['Kategori', 'Tidak', 'Isi kode atau label kategori (default: vip).'],
            ['Status RSVP', 'Tidak', 'Isi kode atau label RSVP (default: menunggu).'],
            ['Catatan', 'Tidak', 'Catatan tambahan.'],
            [],
            ['Kode Kategori', 'Label'],
            ...collect(VipGuest::$kategoriOptions)
                ->map(fn (string $label, string $key): array => [$key, $label])
                ->values()
                ->all(),
            [],
            ['Kode RSVP', 'Label'],
            ...collect(VipGuest::$rsvpOptions)
                ->map(fn (string $label, string $key): array => [$key, $label])
                ->values()
                ->all(),
        ], null, 'A1');
        $guideSheet->getStyle('A1:C1')->getFont()->setBold(true);
        $guideSheet->getStyle('A12:B12')->getFont()->setBold(true);
        $guideSheet->getStyle('A'.(13 + count(VipGuest::$kategoriOptions) + 1).':B'.(13 + count(VipGuest::$kategoriOptions) + 1))->getFont()->setBold(true);

        foreach (range('A', 'C') as $column) {
            $guideSheet->getColumnDimension($column)->setAutoSize(true);
        }

        $spreadsheet->setActiveSheetIndex(0);

        $filePath = ExcelSupport::makeTemporaryXlsxPath('vip_guest_template_');
        (new Xlsx($spreadsheet))->save($filePath);

        return response()->download(
            $filePath,
            'template-tamu-vip.xlsx',
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
        $sheet = $spreadsheet->getSheetByName('Tamu VIP') ?? $spreadsheet->getActiveSheet();
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
        $nextNumber = ((int) $user->vipGuests()->max('no')) + 1;

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

                $user->vipGuests()->create($payload);
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
            'jabatan' => ['jabatan', 'position'],
            'instansi' => ['instansi', 'organisasi', 'company'],
            'phone' => ['telepon', 'phone', 'whatsapp', 'no hp', 'no. hp'],
            'kategori' => ['kategori', 'category'],
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
     *     no: ?int,
     *     name: string,
     *     jabatan: ?string,
     *     instansi: ?string,
     *     phone: ?string,
     *     kategori: string,
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

        $no = $values['no'] ?? '';

        return [
            'no' => $no !== '' && is_numeric($no) ? (int) $no : $fallbackNumber,
            'name' => $values['name'],
            'jabatan' => ($values['jabatan'] ?? '') !== '' ? $values['jabatan'] : null,
            'instansi' => ($values['instansi'] ?? '') !== '' ? $values['instansi'] : null,
            'phone' => ($values['phone'] ?? '') !== '' ? $values['phone'] : null,
            'kategori' => $this->normalizeKategori($values['kategori'] ?? null),
            'rsvp_status' => $this->normalizeRsvpStatus($values['rsvp_status'] ?? null),
            'catatan' => ($values['catatan'] ?? '') !== '' ? $values['catatan'] : null,
        ];
    }

    /**
     * @param  array{
     *     no: ?int,
     *     name: string,
     *     jabatan: ?string,
     *     instansi: ?string,
     *     phone: ?string,
     *     kategori: string,
     *     rsvp_status: string,
     *     catatan: ?string
     * }  $payload
     */
    private function isExampleRow(array $payload): bool
    {
        return Str::lower($payload['name']) === 'bapak contoh nama'
            || Str::contains(Str::lower((string) $payload['catatan']), 'contoh baris data');
    }

    private function normalizeKategori(?string $value): string
    {
        $value = Str::of($value ?? '')->lower()->trim()->toString();

        if ($value === '') {
            return 'vip';
        }

        if (isset(VipGuest::$kategoriOptions[$value])) {
            return $value;
        }

        foreach (VipGuest::$kategoriOptions as $key => $label) {
            if (Str::lower($label) === $value) {
                return $key;
            }
        }

        throw new \InvalidArgumentException("Kategori \"{$value}\" tidak valid.");
    }

    private function normalizeRsvpStatus(?string $value): string
    {
        $value = Str::of($value ?? '')->lower()->trim()->replace(' ', '_')->toString();

        if ($value === '') {
            return 'menunggu';
        }

        if (isset(VipGuest::$rsvpOptions[$value])) {
            return $value;
        }

        foreach (VipGuest::$rsvpOptions as $key => $label) {
            if (Str::lower($label) === Str::of($value)->replace('_', ' ')->toString()) {
                return $key;
            }
        }

        throw new \InvalidArgumentException("Status RSVP \"{$value}\" tidak valid.");
    }
}
