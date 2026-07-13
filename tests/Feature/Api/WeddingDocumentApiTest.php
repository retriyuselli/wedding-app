<?php

namespace Tests\Feature\Api;

use App\Models\CustomerPreparationTask;
use App\Models\CustomerPreparationTaskAttachment;
use App\Models\DocumentFolder;
use App\Models\User;
use App\Models\WeddingDocument;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class WeddingDocumentApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
        Storage::fake('public');
    }

    public function test_user_can_create_folder_and_upload_document(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $folderResponse = $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/document-folders', ['name' => 'Kontrak Vendor']);

        $folderResponse
            ->assertSuccessful()
            ->assertJsonPath('data.name', 'Kontrak Vendor');

        $folderId = $folderResponse->json('data.id');

        $file = UploadedFile::fake()->create('kontrak-vendor.pdf', 120, 'application/pdf');

        $uploadResponse = $this->actingAs($user, 'sanctum')
            ->post('/api/v1/wedding-documents', [
                'file' => $file,
                'document_folder_id' => $folderId,
                'category' => 'vendor',
            ], [
                'Accept' => 'application/json',
            ]);

        $uploadResponse
            ->assertSuccessful()
            ->assertJsonPath('data.file_name', 'kontrak-vendor.pdf')
            ->assertJsonPath('data.category', 'vendor')
            ->assertJsonPath('data.document_folder_id', $folderId);

        $url = $uploadResponse->json('data.url');
        $this->assertIsString($url);
        $this->assertStringContainsString('/storage/', $url);
        $this->assertStringStartsWith('http', $url);

        $this->assertDatabaseHas('wedding_documents', [
            'user_id' => $user->id,
            'file_name' => 'kontrak-vendor.pdf',
            'document_folder_id' => $folderId,
        ]);
    }

    public function test_user_can_download_uploaded_document(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $document = WeddingDocument::factory()->create([
            'user_id' => $user->id,
            'file_name' => 'undangan.pdf',
            'file_path' => 'wedding-documents/undangan.pdf',
            'mime_type' => 'application/pdf',
        ]);

        Storage::disk('public')->put($document->file_path, 'pdf-bytes');

        $response = $this->actingAs($user, 'sanctum')
            ->get("/api/v1/wedding-documents/{$document->id}/download");

        $response
            ->assertOk()
            ->assertHeader('content-disposition');

        $this->assertSame('pdf-bytes', $response->streamedContent());
    }

    public function test_user_cannot_download_another_users_document(): void
    {
        $owner = User::where('email', 'test@example.com')->firstOrFail();
        $other = User::factory()->create();
        $document = WeddingDocument::factory()->create([
            'user_id' => $owner->id,
            'file_path' => 'wedding-documents/private.pdf',
        ]);

        Storage::disk('public')->put($document->file_path, 'secret');

        $this->actingAs($other, 'sanctum')
            ->get("/api/v1/wedding-documents/{$document->id}/download")
            ->assertNotFound();
    }

    public function test_index_includes_checklist_attachments(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $task = CustomerPreparationTask::factory()->create([
            'user_id' => $user->id,
            'title' => 'Meeting vendor dekorasi',
        ]);

        CustomerPreparationTaskAttachment::query()->create([
            'user_id' => $user->id,
            'preparation_task_id' => $task->id,
            'file_name' => 'Kontrak_Test_Vendor.pdf',
            'file_path' => 'preparation-attachments/demo.pdf',
            'file_size' => 2048,
            'mime_type' => 'application/pdf',
        ]);

        WeddingDocument::factory()->create([
            'user_id' => $user->id,
            'file_name' => 'anggaran.xlsx',
            'category' => 'keuangan',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-documents');

        $response->assertOk();
        $this->assertGreaterThanOrEqual(2, count($response->json('data')));
    }

    public function test_summary_returns_storage_and_counts(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        WeddingDocument::factory()->create([
            'user_id' => $user->id,
            'file_size' => 2048,
            'category' => 'vendor',
        ]);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/wedding-documents/summary')
            ->assertOk()
            ->assertJsonPath('data.used_bytes', 2048)
            ->assertJsonPath('data.quota_bytes', WeddingDocument::STORAGE_QUOTA_BYTES)
            ->assertJsonPath('data.counts.vendor', 1);
    }

    public function test_user_can_delete_uploaded_document_and_folder(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $folder = DocumentFolder::factory()->create(['user_id' => $user->id, 'name' => 'Temp']);
        $document = WeddingDocument::factory()->create([
            'user_id' => $user->id,
            'document_folder_id' => $folder->id,
            'file_path' => 'wedding-documents/temp.pdf',
        ]);

        Storage::disk('public')->put($document->file_path, 'dummy');

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/wedding-documents/{$document->id}")
            ->assertNoContent();

        $this->assertDatabaseMissing('wedding_documents', ['id' => $document->id]);

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/document-folders/{$folder->id}")
            ->assertNoContent();

        $this->assertDatabaseMissing('document_folders', ['id' => $folder->id]);
    }
}
