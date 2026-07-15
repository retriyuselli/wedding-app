<?php

namespace App\Exceptions;

use Illuminate\Support\Str;
use RuntimeException;
use Throwable;

class ExcelUnavailableException extends RuntimeException
{
    public static function from(Throwable $previous): self
    {
        if ($previous instanceof self) {
            return $previous;
        }

        $message = $previous->getMessage();

        if (
            str_contains($message, 'ZipArchive')
            || str_contains($message, 'Class "ZipArchive"')
            || str_contains(strtolower($message), 'zip archive')
        ) {
            return new self(
                'Server belum siap untuk Excel. Aktifkan ekstensi PHP "zip" di Hostinger (hPanel → PHP Configuration → Extensions), lalu coba lagi.',
                previous: $previous,
            );
        }

        if (
            str_contains(strtolower($message), 'permission')
            || str_contains(strtolower($message), 'read-only')
            || str_contains(strtolower($message), 'failed to open stream')
        ) {
            return new self(
                'Server gagal menulis file Excel sementara. Periksa permission folder storage/ (chmod -R ug+rwx storage bootstrap/cache).',
                previous: $previous,
            );
        }

        $safeDetail = trim(Str::limit(preg_replace('/\s+/', ' ', $message) ?? $message, 180));

        return new self(
            $safeDetail !== ''
                ? "Gagal memproses file Excel di server: {$safeDetail}"
                : 'Gagal memproses file Excel di server. Coba lagi atau hubungi admin jika berulang.',
            previous: $previous,
        );
    }
}
