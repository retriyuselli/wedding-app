<?php

namespace App\Services\Privacy;

use App\Models\User;
use Illuminate\Support\Facades\Storage;
use ZipArchive;

class UserDataExportService
{
    /**
     * Build a ZIP archive of the user's account data and return the absolute path.
     */
    public function createZip(User $user): string
    {
        $payload = $this->payload($user);
        $relativeDir = 'exports/'.$user->id;
        $disk = Storage::disk('local');
        $disk->makeDirectory($relativeDir);

        $jsonRelative = $relativeDir.'/account-data.json';
        $zipRelative = $relativeDir.'/wedding-app-data-export.zip';

        $disk->put($jsonRelative, json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

        $jsonPath = $disk->path($jsonRelative);
        $zipPath = $disk->path($zipRelative);

        $zip = new ZipArchive;

        if ($zip->open($zipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE) !== true) {
            abort(500, 'Gagal membuat arsip ekspor data.');
        }

        $zip->addFile($jsonPath, 'account-data.json');
        $zip->close();

        $disk->delete($jsonRelative);

        return $zipPath;
    }

    /**
     * @return array<string, mixed>
     */
    public function payload(User $user): array
    {
        $user->loadMissing([
            'weddingInfo',
            'weddingEvents',
            'weddingBudget',
            'guests',
            'vipGuests',
            'familyMembers',
            'paymentSchedules',
            'incomingPayments',
            'weddingDocuments',
            'documentFolders',
            'preparationSections.tasks',
        ]);

        return [
            'exported_at' => now()->toIso8601String(),
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'whatsapp' => $user->whatsapp,
                'privacy_settings' => $user->privacy_settings,
                'notification_settings' => $user->notification_settings,
                'two_factor_enabled' => (bool) $user->two_factor_enabled,
                'created_at' => $user->created_at?->toIso8601String(),
            ],
            'wedding_info' => $user->weddingInfo,
            'wedding_events' => $user->weddingEvents,
            'wedding_budget' => $user->weddingBudget,
            'guests' => $user->guests,
            'vip_guests' => $user->vipGuests,
            'family_members' => $user->familyMembers,
            'payment_schedules' => $user->paymentSchedules,
            'incoming_payments' => $user->incomingPayments,
            'document_folders' => $user->documentFolders,
            'wedding_documents' => $user->weddingDocuments->map(fn ($document) => [
                'id' => $document->id,
                'file_name' => $document->file_name,
                'category' => $document->category,
                'file_size' => $document->file_size,
                'mime_type' => $document->mime_type,
                'created_at' => $document->created_at?->toIso8601String(),
            ]),
            'preparation_sections' => $user->preparationSections,
        ];
    }
}
