<?php

namespace Tests\Feature;

use App\Models\CustomerPreparationTask;
use App\Models\CustomerPreparationTaskAttachment;
use App\Models\User;
use App\Models\WeddingInfo;
use App\Support\DocumentFolder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class DokumenPageTest extends TestCase
{
    use RefreshDatabase;

    public function test_documents_page_requires_authentication(): void
    {
        $this->get(route('dokumen'))->assertRedirect(route('login'));
    }

    public function test_documents_page_shows_redesigned_layout(): void
    {
        $user = User::factory()
            ->has(WeddingInfo::factory()->state([
                'groom_name' => 'Rama',
                'bride_name' => 'Anya',
            ]))
            ->create();

        $response = $this->actingAs($user)->get(route('dokumen'));

        $response->assertOk();
        $response->assertSee('Dokumen Pernikahan');
        $response->assertSee('Simpan dan kelola semua dokumen penting pernikahan Anda di sini.');
        $response->assertSee('Folder Saya');
        $response->assertSee('Semua Dokumen');
        $response->assertSee('Kontrak Vendor');
        $response->assertSee('Penyimpanan');
        $response->assertSee('Terbaru Diupload');
        $response->assertSee('Tips Menyimpan Dokumen');
        $response->assertSee('Kontrak_Venue_Aston.pdf');
    }

    public function test_documents_page_can_filter_by_folder(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get(route('dokumen', ['folder' => DocumentFolder::Finance]));

        $response->assertOk();
        $response->assertSee('Keuangan');
        $response->assertSee('Rincian_Budget_2026.xlsx');
        $response->assertDontSee('Fotokopi_KTP_Mempelai.pdf');
    }

    public function test_documents_page_shows_real_attachments_when_available(): void
    {
        Storage::fake('public');

        $user = User::factory()->create();
        $task = CustomerPreparationTask::factory()->for($user)->create([
            'title' => 'Kontrak vendor venue',
        ]);

        $filePath = "preparation-attachments/{$task->id}-test.pdf";
        Storage::disk('public')->put($filePath, 'sample pdf content');

        CustomerPreparationTaskAttachment::query()->create([
            'user_id' => $user->id,
            'preparation_task_id' => $task->id,
            'file_name' => 'Kontrak_Test_Vendor.pdf',
            'file_path' => $filePath,
            'file_size' => 1024,
            'mime_type' => 'application/pdf',
        ]);

        $response = $this->actingAs($user)->get(route('dokumen', ['q' => 'Kontrak_Test_Vendor']));

        $response->assertOk();
        $response->assertSee('Kontrak_Test_Vendor.pdf');
        $response->assertDontSee('Kontrak_Venue_Aston.pdf');
    }
}
