<?php

namespace Database\Seeders;

use App\Models\DocumentFolder;
use App\Models\User;
use Illuminate\Database\Seeder;

class DocumentFolderSeeder extends Seeder
{
    /**
     * @var list<array{name: string, sort_order: int}>
     */
    private const FOLDERS = [
        ['name' => 'Kontrak Vendor', 'sort_order' => 1],
        ['name' => 'Keuangan', 'sort_order' => 2],
        ['name' => 'Dokumen Resmi', 'sort_order' => 3],
        ['name' => 'Desain & Undangan', 'sort_order' => 4],
    ];

    public function run(): void
    {
        User::query()->each(function (User $user): void {
            foreach (self::FOLDERS as $folder) {
                DocumentFolder::query()->updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'name' => $folder['name'],
                    ],
                    [
                        'sort_order' => $folder['sort_order'],
                    ],
                );
            }
        });
    }
}
