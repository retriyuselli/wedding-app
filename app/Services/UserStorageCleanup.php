<?php

namespace App\Services;

use App\Models\CustomerPreparationTaskAttachment;
use App\Models\User;
use App\Models\WeddingDocument;
use App\Models\WeddingIncomingPayment;
use App\Models\WeddingPaymentSchedule;
use Illuminate\Support\Facades\Storage;

class UserStorageCleanup
{
    /**
     * Remove all known user-owned files from public (and local) storage.
     * Call before the user row is deleted so related paths can still be read.
     */
    public function cleanup(User $user): void
    {
        $public = Storage::disk('public');
        $local = Storage::disk('local');

        $this->deleteDirectoryIfExists($public, 'couple-photos/'.$user->id);
        $this->deleteDirectoryIfExists($public, 'wedding-documents/'.$user->id);
        $this->deleteDirectoryIfExists($public, 'exports/'.$user->id);
        $this->deleteDirectoryIfExists($local, 'exports/'.$user->id);

        $this->deleteStoredPath($public, $user->weddingInfo?->couple_photo);
        $this->deleteStoredPath($public, $user->avatar_url);

        WeddingDocument::query()
            ->where('user_id', $user->id)
            ->pluck('file_path')
            ->each(fn (?string $path) => $this->deleteStoredPath($public, $path));

        WeddingPaymentSchedule::query()
            ->where('user_id', $user->id)
            ->pluck('proof_url')
            ->each(fn (?string $path) => $this->deleteStoredPath($public, $path));

        WeddingIncomingPayment::query()
            ->where('user_id', $user->id)
            ->pluck('proof_url')
            ->each(fn (?string $path) => $this->deleteStoredPath($public, $path));

        CustomerPreparationTaskAttachment::query()
            ->where('user_id', $user->id)
            ->pluck('file_path')
            ->each(fn (?string $path) => $this->deleteStoredPath($public, $path));
    }

    private function deleteDirectoryIfExists($disk, string $directory): void
    {
        if ($disk->exists($directory)) {
            $disk->deleteDirectory($directory);
        }
    }

    private function deleteStoredPath($disk, ?string $path): void
    {
        if (! is_string($path) || trim($path) === '') {
            return;
        }

        $path = ltrim($path, '/');

        // External URLs (Google/Apple avatar, etc.) are not on our disk.
        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return;
        }

        if (str_starts_with($path, 'storage/')) {
            $path = substr($path, strlen('storage/'));
        }

        if ($disk->exists($path)) {
            $disk->delete($path);
        }
    }
}
