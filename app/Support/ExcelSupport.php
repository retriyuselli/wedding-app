<?php

namespace App\Support;

use App\Exceptions\ExcelUnavailableException;
use Illuminate\Support\Facades\File;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

final class ExcelSupport
{
    /**
     * Validation rules that tolerate MIME sniffing differences between
     * local macOS PHP and Hostinger / shared hosting.
     *
     * @return list<string|\Illuminate\Contracts\Validation\ValidationRule>
     */
    public static function spreadsheetUploadRules(int $maxKilobytes = 5120): array
    {
        return [
            'required',
            'file',
            'max:'.$maxKilobytes,
            'extensions:xlsx',
            'mimetypes:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/octet-stream,application/zip,application/vnd.ms-excel',
        ];
    }

    public static function ensureZipAvailable(): void
    {
        if (class_exists(\ZipArchive::class)) {
            return;
        }

        throw new ExcelUnavailableException(
            'Server belum siap untuk Excel. Aktifkan ekstensi PHP "zip" di Hostinger (hPanel → PHP Configuration → Extensions), lalu coba lagi.'
        );
    }

    /**
     * Hostinger often blocks or cleans sys_get_temp_dir(); keep Excel files under storage/.
     */
    public static function makeTemporaryXlsxPath(string $prefix = 'excel_'): string
    {
        $directory = storage_path('app/tmp/excel');

        if (! File::isDirectory($directory)) {
            File::makeDirectory($directory, 0755, true);
        }

        if (! is_writable($directory)) {
            throw new ExcelUnavailableException(
                'Folder storage/app/tmp/excel tidak bisa ditulis. Periksa permission folder storage di server.'
            );
        }

        $filePath = $directory.DIRECTORY_SEPARATOR.uniqid($prefix, true).'.xlsx';

        // Touch an empty file so download()->deleteFileAfterSend always has a path.
        if (file_put_contents($filePath, '') === false) {
            throw new ExcelUnavailableException(
                'Gagal membuat file sementara Excel di storage. Periksa permission folder storage.'
            );
        }

        return $filePath;
    }

    /**
     * Quick smoke-test used by artisan excel:diagnose.
     */
    public static function smokeWrite(): string
    {
        self::ensureZipAvailable();

        $filePath = self::makeTemporaryXlsxPath('diagnose_');
        $spreadsheet = new Spreadsheet;
        $spreadsheet->getActiveSheet()->setCellValue('A1', 'Wedding App Excel OK');
        (new Xlsx($spreadsheet))->save($filePath);

        return $filePath;
    }
}
