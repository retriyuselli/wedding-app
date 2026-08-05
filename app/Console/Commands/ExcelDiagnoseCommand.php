<?php

namespace App\Console\Commands;

use App\Support\ExcelSupport;
use Illuminate\Console\Command;
use Throwable;

class ExcelDiagnoseCommand extends Command
{
    protected $signature = 'excel:diagnose';

    protected $description = 'Cek kesiapan server untuk generate/import Excel (zip, storage, smoke write)';

    public function handle(): int
    {
        $this->components->info('Diagnosa Excel / PhpSpreadsheet');

        $this->line('PHP binary: '.PHP_BINARY);
        $this->line('PHP version: '.PHP_VERSION);
        $this->line('ZipArchive: '.(class_exists(\ZipArchive::class) ? 'OK' : 'MISSING'));
        $this->line('storage path: '.storage_path());
        $this->line('storage writable: '.(is_writable(storage_path()) ? 'OK' : 'NO'));
        $this->line('storage/app writable: '.(is_writable(storage_path('app')) ? 'OK' : 'NO'));

        try {
            $path = ExcelSupport::smokeWrite();
            $size = filesize($path) ?: 0;
            @unlink($path);
            $this->components->info("Smoke write OK ({$size} bytes).");

            return self::SUCCESS;
        } catch (Throwable $exception) {
            $this->components->error($exception->getMessage());

            return self::FAILURE;
        }
    }
}
