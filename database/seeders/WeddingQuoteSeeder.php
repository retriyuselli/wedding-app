<?php

namespace Database\Seeders;

use App\Models\WeddingQuote;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class WeddingQuoteSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * @var list<string>
     */
    private const QUOTES = [
        'Pernikahan yang sempurna bukan soal detailnya, melainkan tentang merayakan cinta kalian.',
        'Pernikahan bukan hanya tentang hari pernikahan, tapi tentang semua hari setelahnya.',
        'Dua jiwa, satu hati — awal dari kebersamaan yang indah selamanya.',
    ];

    public function run(): void
    {
        foreach (self::QUOTES as $index => $quote) {
            WeddingQuote::query()->updateOrCreate(
                ['quote' => $quote],
                [
                    'sort_order' => $index + 1,
                    'is_active' => true,
                ],
            );
        }
    }
}
