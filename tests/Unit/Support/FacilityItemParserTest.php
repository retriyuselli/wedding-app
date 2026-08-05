<?php

namespace Tests\Unit\Support;

use App\Support\FacilityItemParser;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

class FacilityItemParserTest extends TestCase
{
    public function test_from_text_splits_multiline_paste_and_strips_numbering(): void
    {
        $text = <<<'TEXT'
1. Dekorasi lamaran dan meja kursi
2) Menu Ayam, Ikan, daging
3 - Photographer dan videographer lamaran
• Hantaran 10 akrilik
- 1 orang Profesional MC
TEXT;

        $this->assertSame([
            'Dekorasi lamaran dan meja kursi',
            'Menu Ayam, Ikan, daging',
            'Photographer dan videographer lamaran',
            'Hantaran 10 akrilik',
            '1 orang Profesional MC',
        ], FacilityItemParser::fromText($text));
    }

    public function test_to_text_joins_items_with_newlines(): void
    {
        $this->assertSame(
            "Item pertama\nItem kedua",
            FacilityItemParser::toText(['Item pertama', 'Item kedua']),
        );
    }

    #[DataProvider('cleanLineProvider')]
    public function test_clean_line(string $input, string $expected): void
    {
        $this->assertSame($expected, FacilityItemParser::cleanLine($input));
    }

    /**
     * @return array<string, array{0: string, 1: string}>
     */
    public static function cleanLineProvider(): array
    {
        return [
            'numbered dot' => ['1. Sewa ballroom 6 jam', 'Sewa ballroom 6 jam'],
            'numbered paren' => ['(2) Sound system', 'Sound system'],
            'bullet dash' => ['- Parking area', 'Parking area'],
            'plain text' => ['Dedicated event team', 'Dedicated event team'],
        ];
    }
}
