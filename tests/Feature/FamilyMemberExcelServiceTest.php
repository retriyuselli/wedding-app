<?php

namespace Tests\Feature;

use App\Models\FamilyMember;
use App\Models\User;
use App\Services\FamilyMemberExcelService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Tests\TestCase;

class FamilyMemberExcelServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_template_download_returns_xlsx_file(): void
    {
        $response = app(FamilyMemberExcelService::class)->downloadTemplate();

        $this->assertTrue($response->headers->contains('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'));
        $this->assertStringContainsString('template-anggota-keluarga.xlsx', (string) $response->headers->get('content-disposition'));
    }

    public function test_import_creates_family_members_from_spreadsheet(): void
    {
        $user = User::factory()->create();
        $filePath = $this->createSpreadsheetFile([
            FamilyMemberExcelService::TEMPLATE_HEADERS,
            [1, 'Bapak Andi', 'Ayah', '0811111111', 'hadir'],
            [2, 'Ibu Siti', 'Ibu', '0822222222', 'menunggu'],
        ]);

        $result = app(FamilyMemberExcelService::class)->import($user, $filePath);

        $this->assertSame(2, $result['imported']);
        $this->assertSame(0, $result['skipped']);
        $this->assertSame([], $result['errors']);

        $this->assertDatabaseHas('family_members', [
            'user_id' => $user->id,
            'name' => 'Bapak Andi',
            'role' => 'Ayah',
            'rsvp_status' => 'hadir',
        ]);

        $this->assertDatabaseHas('family_members', [
            'user_id' => $user->id,
            'name' => 'Ibu Siti',
            'role' => 'Ibu',
            'rsvp_status' => 'menunggu',
        ]);
    }

    public function test_import_skips_example_row_from_template(): void
    {
        $user = User::factory()->create();
        $filePath = $this->createSpreadsheetFile([
            FamilyMemberExcelService::TEMPLATE_HEADERS,
            [1, 'Bapak Contoh Nama', 'Ayah', '081234567890', 'menunggu', 'Contoh baris data. Hapus sebelum upload.'],
            [2, 'Anggota Asli', 'Kakak', null, 'menunggu'],
        ]);

        $result = app(FamilyMemberExcelService::class)->import($user, $filePath);

        $this->assertSame(1, $result['imported']);
        $this->assertSame(1, $result['skipped']);
        $this->assertSame(1, FamilyMember::query()->where('user_id', $user->id)->count());
    }

    /**
     * @param  list<list<int|string|null>>  $rows
     */
    private function createSpreadsheetFile(array $rows): string
    {
        $spreadsheet = new Spreadsheet;
        $spreadsheet->getActiveSheet()->setTitle('Anggota Keluarga');
        $spreadsheet->getActiveSheet()->fromArray($rows, null, 'A1');

        $tempPath = tempnam(sys_get_temp_dir(), 'family_member_import_test_');
        $filePath = $tempPath.'.xlsx';
        rename($tempPath, $filePath);

        (new Xlsx($spreadsheet))->save($filePath);

        return $filePath;
    }
}
