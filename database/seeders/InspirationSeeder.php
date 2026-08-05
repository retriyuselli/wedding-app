<?php

namespace Database\Seeders;

use App\Models\Inspiration;
use Illuminate\Database\Seeder;

class InspirationSeeder extends Seeder
{
    public function run(): void
    {
        Inspiration::query()->delete();

        $items = [
            [
                'title' => 'Dekorasi Akad Minimalis',
                'description' => 'Konsep akad nikah dengan dekorasi sederhana, elegan, dan nuansa natural.',
                'category' => 'dekorasi',
                'image_url' => null,
                'thumbnail_symbol' => 'leaf.fill',
                'likes_count' => 256,
                'views_count' => 1200,
                'sort_order' => 1,
            ],
            [
                'title' => 'Gaun Pengantin Modern',
                'description' => 'Inspirasi gaun putih modern dengan detail renda halus dan siluet A-line.',
                'category' => 'gaun',
                'image_url' => null,
                'thumbnail_symbol' => 'figure.dress.line.vertical',
                'likes_count' => 312,
                'views_count' => 1450,
                'sort_order' => 2,
            ],
            [
                'title' => 'Makeup Natural Glow',
                'description' => 'Tampilan makeup pengantin natural dengan kulit glowing dan bibir nude.',
                'category' => 'makeup',
                'image_url' => null,
                'thumbnail_symbol' => 'paintbrush.fill',
                'likes_count' => 198,
                'views_count' => 980,
                'sort_order' => 3,
            ],
            [
                'title' => 'Menu Katering Premium',
                'description' => 'Konsep menu prasmanan premium dengan hidangan Indonesia dan internasional.',
                'category' => 'katering',
                'image_url' => null,
                'thumbnail_symbol' => 'fork.knife',
                'likes_count' => 145,
                'views_count' => 760,
                'sort_order' => 4,
            ],
            [
                'title' => 'Venue Outdoor Garden',
                'description' => 'Lokasi pernikahan outdoor dengan taman hijau dan panggung kayu rustic.',
                'category' => 'venue',
                'image_url' => null,
                'thumbnail_symbol' => 'building.2.fill',
                'likes_count' => 287,
                'views_count' => 1320,
                'sort_order' => 5,
            ],
            [
                'title' => 'Dekorasi Resepsi Glamour',
                'description' => 'Dekorasi resepsi dengan chandelier, bunga putih, dan nuansa emas.',
                'category' => 'dekorasi',
                'image_url' => null,
                'thumbnail_symbol' => 'sparkles',
                'likes_count' => 224,
                'views_count' => 1100,
                'sort_order' => 6,
            ],
            [
                'title' => 'Gaun Pengantin Vintage',
                'description' => 'Gaun vintage dengan lengan panjang dan detail bordir klasik.',
                'category' => 'gaun',
                'image_url' => null,
                'thumbnail_symbol' => 'figure.dress.line.vertical',
                'likes_count' => 176,
                'views_count' => 890,
                'sort_order' => 7,
            ],
            [
                'title' => 'Makeup Bold Glamour',
                'description' => 'Makeup bold dengan smoky eyes dan lip merah untuk tampilan glamor.',
                'category' => 'makeup',
                'image_url' => null,
                'thumbnail_symbol' => 'paintbrush.fill',
                'likes_count' => 134,
                'views_count' => 720,
                'sort_order' => 8,
            ],
            [
                'title' => 'Katering Prasmanan Nusantara',
                'description' => 'Menu prasmanan dengan hidangan khas Nusantara dan live cooking station.',
                'category' => 'katering',
                'image_url' => null,
                'thumbnail_symbol' => 'fork.knife',
                'likes_count' => 112,
                'views_count' => 640,
                'sort_order' => 9,
            ],
            [
                'title' => 'Venue Ballroom Elegan',
                'description' => 'Ballroom elegan dengan kapasitas besar dan pencahayaan dramatis.',
                'category' => 'venue',
                'image_url' => null,
                'thumbnail_symbol' => 'building.2.fill',
                'likes_count' => 265,
                'views_count' => 1180,
                'sort_order' => 10,
            ],
        ];

        foreach ($items as $item) {
            Inspiration::create($item);
        }
    }
}
