<?php

namespace Tests\Feature;

use App\Models\Guest;
use App\Models\User;
use App\Services\GuestExcelService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use Tests\TestCase;

class GuestExcelServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_template_download_returns_xlsx_file(): void
    {
        $response = app(GuestExcelService::class)->downloadTemplate();

        $this->assertTrue($response->headers->contains('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'));
        $this->assertStringContainsString('template-daftar-tamu.xlsx', (string) $response->headers->get('content-disposition'));
    }

    public function test_import_creates_guests_from_spreadsheet(): void
    {
        $user = User::factory()->create();
        $filePath = $this->createSpreadsheetFile([
            GuestExcelService::TEMPLATE_HEADERS,
            [1, 'Bapak Andi', '0811111111', 'andi@example.com', '5', 'hadir', 'Tamu keluarga'],
            [2, 'Ibu Siti', '0822222222', null, '6', 'menunggu', null],
        ]);

        $result = app(GuestExcelService::class)->import($user, $filePath);

        $this->assertSame(2, $result['imported']);
        $this->assertSame(0, $result['skipped']);
        $this->assertSame([], $result['errors']);

        $this->assertDatabaseHas('guests', [
            'user_id' => $user->id,
            'no' => 1,
            'name' => 'Bapak Andi',
            'email' => 'andi@example.com',
            'table_number' => '5',
            'rsvp_status' => 'hadir',
        ]);

        $this->assertDatabaseHas('guests', [
            'user_id' => $user->id,
            'no' => 2,
            'name' => 'Ibu Siti',
            'rsvp_status' => 'menunggu',
        ]);
    }

    public function test_import_uses_row_number_for_display_order_not_alphabet(): void
    {
        $user = User::factory()->create();
        $filePath = $this->createSpreadsheetFile([
            GuestExcelService::TEMPLATE_HEADERS,
            [2, 'Zebra', null, null, null, 'menunggu', null],
            [1, 'Alpha', null, null, null, 'menunggu', null],
        ]);

        $result = app(GuestExcelService::class)->import($user, $filePath);

        $this->assertSame(2, $result['imported']);

        $ordered = Guest::query()
            ->where('user_id', $user->id)
            ->orderBy('no')
            ->orderBy('name')
            ->pluck('name')
            ->all();

        $this->assertSame(['Alpha', 'Zebra'], $ordered);
    }

    public function test_import_skips_example_row_from_template(): void
    {
        $user = User::factory()->create();
        $filePath = $this->createSpreadsheetFile([
            GuestExcelService::TEMPLATE_HEADERS,
            [1, 'Bapak Contoh Nama', '081234567890', 'contoh@email.com', '12', 'menunggu', 'Contoh baris data. Hapus sebelum upload.'],
            [2, 'Tamu Asli', null, null, null, 'menunggu', null],
        ]);

        $result = app(GuestExcelService::class)->import($user, $filePath);

        $this->assertSame(1, $result['imported']);
        $this->assertSame(1, $result['skipped']);
        $this->assertSame(1, Guest::query()->where('user_id', $user->id)->count());
    }

    /**
     * @param  list<list<int|string|null>>  $rows
     */
    private function createSpreadsheetFile(array $rows): string
    {
        $spreadsheet = new Spreadsheet;
        $spreadsheet->getActiveSheet()->setTitle('Daftar Tamu');
        $spreadsheet->getActiveSheet()->fromArray($rows, null, 'A1');

        $tempPath = tempnam(sys_get_temp_dir(), 'guest_import_test_');
        $filePath = $tempPath.'.xlsx';
        rename($tempPath, $filePath);

        (new Xlsx($spreadsheet))->save($filePath);

        return $filePath;
    }
}
