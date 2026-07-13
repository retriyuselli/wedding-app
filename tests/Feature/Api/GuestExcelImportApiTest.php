<?php

namespace Tests\Feature\Api;

use App\Models\Guest;
use App\Models\User;
use App\Models\VipGuest;
use App\Services\FamilyMemberExcelService;
use App\Services\GuestExcelService;
use App\Services\VipGuestExcelService;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Tests\TestCase;

class GuestExcelImportApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([UserSeeder::class]);
    }

    public function test_guest_template_download_returns_xlsx(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->get('/api/v1/guests-excel-template');

        $response->assertOk();
        $this->assertStringContainsString(
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            (string) $response->headers->get('content-type'),
        );
        $this->assertStringContainsString(
            'template-daftar-tamu.xlsx',
            (string) $response->headers->get('content-disposition'),
        );
    }

    public function test_guest_import_excel_creates_records_for_authenticated_user(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();
        $file = $this->uploadedSpreadsheet('Daftar Tamu', [
            GuestExcelService::TEMPLATE_HEADERS,
            [1, 'Bapak Andi', '0811111111', 'andi@example.com', '5', 'hadir', 'Tamu keluarga'],
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->post('/api/v1/guests-import-excel', [
                'spreadsheet' => $file,
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.imported', 1)
            ->assertJsonPath('data.skipped', 0);

        $this->assertDatabaseHas('guests', [
            'user_id' => $user->id,
            'name' => 'Bapak Andi',
            'email' => 'andi@example.com',
            'rsvp_status' => 'hadir',
        ]);
    }

    public function test_vip_template_and_import_work(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->get('/api/v1/vip-guests-excel-template')
            ->assertOk();

        $file = $this->uploadedSpreadsheet('Tamu VIP', [
            VipGuestExcelService::TEMPLATE_HEADERS,
            [1, 'Ibu VIP', 'Direktur', 'Pemda', '0812222222', 'vip', 'menunggu', 'Catatan VIP'],
        ]);

        $this->actingAs($user, 'sanctum')
            ->post('/api/v1/vip-guests-import-excel', [
                'spreadsheet' => $file,
            ])
            ->assertOk()
            ->assertJsonPath('data.imported', 1);

        $this->assertDatabaseHas('vip_guests', [
            'user_id' => $user->id,
            'name' => 'Ibu VIP',
            'kategori' => 'vip',
        ]);
        $this->assertInstanceOf(VipGuest::class, VipGuest::query()->where('name', 'Ibu VIP')->first());
    }

    public function test_family_template_and_import_work(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->get('/api/v1/family-members-excel-template')
            ->assertOk();

        $file = $this->uploadedSpreadsheet('Anggota Keluarga', [
            FamilyMemberExcelService::TEMPLATE_HEADERS,
            [1, 'Paman Budi', 'Paman', '0813333333', 'hadir'],
        ]);

        $this->actingAs($user, 'sanctum')
            ->post('/api/v1/family-members-import-excel', [
                'spreadsheet' => $file,
            ])
            ->assertOk()
            ->assertJsonPath('data.imported', 1);

        $this->assertDatabaseHas('family_members', [
            'user_id' => $user->id,
            'name' => 'Paman Budi',
            'role' => 'Paman',
            'rsvp_status' => 'hadir',
        ]);
    }

    public function test_import_rejects_non_xlsx_file(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->post('/api/v1/guests-import-excel', [
                'spreadsheet' => UploadedFile::fake()->create('notes.txt', 10, 'text/plain'),
            ]);

        $response->assertUnprocessable();
        $this->assertSame(0, Guest::query()->where('user_id', $user->id)->count());
    }

    public function test_import_rejects_file_larger_than_five_megabytes(): void
    {
        $user = User::where('email', 'test@example.com')->firstOrFail();

        $response = $this->actingAs($user, 'sanctum')
            ->post('/api/v1/guests-import-excel', [
                'spreadsheet' => UploadedFile::fake()->create(
                    'guests.xlsx',
                    5121,
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                ),
            ]);

        $response->assertUnprocessable();
    }

    /**
     * @param  list<list<mixed>>  $rows
     */
    private function uploadedSpreadsheet(string $sheetTitle, array $rows): UploadedFile
    {
        $spreadsheet = new Spreadsheet;
        $sheet = $spreadsheet->getActiveSheet();
        $sheet->setTitle($sheetTitle);
        $sheet->fromArray($rows, null, 'A1');

        $tempPath = tempnam(sys_get_temp_dir(), 'guest_api_import_');
        $filePath = $tempPath.'.xlsx';
        rename($tempPath, $filePath);

        (new Xlsx($spreadsheet))->save($filePath);

        return new UploadedFile(
            $filePath,
            'import.xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            null,
            true,
        );
    }
}
