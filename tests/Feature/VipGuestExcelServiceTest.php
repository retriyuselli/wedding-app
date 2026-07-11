<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\VipGuest;
use App\Services\VipGuestExcelService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Tests\TestCase;

class VipGuestExcelServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_template_download_returns_xlsx_file(): void
    {
        $response = app(VipGuestExcelService::class)->downloadTemplate();

        $this->assertTrue($response->headers->contains('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'));
        $this->assertStringContainsString('template-tamu-vip.xlsx', (string) $response->headers->get('content-disposition'));
    }

    public function test_import_creates_vip_guests_from_spreadsheet(): void
    {
        $user = User::factory()->create();
        $filePath = $this->createSpreadsheetFile([
            VipGuestExcelService::TEMPLATE_HEADERS,
            [1, 'Bapak Andi', 'Direktur', 'Dinas Pendidikan', '0811111111', 'pejabat', 'hadir', 'Tamu penting'],
            [2, 'Ibu Siti', 'Ketua RT', 'RT 05', '0822222222', 'tokoh_masyarakat', 'menunggu', null],
        ]);

        $result = app(VipGuestExcelService::class)->import($user, $filePath);

        $this->assertSame(2, $result['imported']);
        $this->assertSame(0, $result['skipped']);
        $this->assertSame([], $result['errors']);

        $this->assertDatabaseHas('vip_guests', [
            'user_id' => $user->id,
            'name' => 'Bapak Andi',
            'kategori' => 'pejabat',
            'rsvp_status' => 'hadir',
        ]);

        $this->assertDatabaseHas('vip_guests', [
            'user_id' => $user->id,
            'name' => 'Ibu Siti',
            'kategori' => 'tokoh_masyarakat',
            'rsvp_status' => 'menunggu',
        ]);
    }

    public function test_import_skips_example_row_from_template(): void
    {
        $user = User::factory()->create();
        $filePath = $this->createSpreadsheetFile([
            VipGuestExcelService::TEMPLATE_HEADERS,
            [1, 'Bapak Contoh Nama', 'Direktur', 'Pemerintah Daerah', '081234567890', 'vip', 'menunggu', 'Contoh baris data. Hapus sebelum upload.'],
            [2, 'Tamu Asli', null, null, null, 'vip', 'menunggu', null],
        ]);

        $result = app(VipGuestExcelService::class)->import($user, $filePath);

        $this->assertSame(1, $result['imported']);
        $this->assertSame(1, $result['skipped']);
        $this->assertSame(1, VipGuest::query()->where('user_id', $user->id)->count());
    }

    /**
     * @param  list<list<int|string|null>>  $rows
     */
    private function createSpreadsheetFile(array $rows): string
    {
        $spreadsheet = new Spreadsheet;
        $spreadsheet->getActiveSheet()->setTitle('Tamu VIP');
        $spreadsheet->getActiveSheet()->fromArray($rows, null, 'A1');

        $tempPath = tempnam(sys_get_temp_dir(), 'vip_guest_import_test_');
        $filePath = $tempPath.'.xlsx';
        rename($tempPath, $filePath);

        (new Xlsx($spreadsheet))->save($filePath);

        return $filePath;
    }
}
