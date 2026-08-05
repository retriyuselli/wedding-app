<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * @var list<array{name: string, slug: string, icon: string|null, description: string|null, sort_order: int, is_active: bool}>
     */
    private const CATEGORIES = [
        [
            'name' => 'Venue',
            'slug' => 'venue',
            'icon' => 'building.columns',
            'description' => 'Gedung, ballroom, hotel, villa, dan venue pernikahan indoor maupun outdoor.',
            'sort_order' => 1,
            'is_active' => true,
        ],
        [
            'name' => 'Catering',
            'slug' => 'catering',
            'icon' => 'fork.knife',
            'description' => 'Jasa catering prasmanan, buffet, snack box, dan coffee break pernikahan.',
            'sort_order' => 2,
            'is_active' => true,
        ],
        [
            'name' => 'Dekorasi',
            'slug' => 'dekorasi',
            'icon' => 'leaf',
            'description' => 'Dekorasi pelaminan, backdrop, aisle, lighting decor, dan styling acara.',
            'sort_order' => 3,
            'is_active' => true,
        ],
        [
            'name' => 'Florist',
            'slug' => 'florist',
            'icon' => 'camera.macro',
            'description' => 'Rangkaian bunga, hand bouquet, center piece, dan dekorasi floral.',
            'sort_order' => 4,
            'is_active' => true,
        ],
        [
            'name' => 'Fotografi',
            'slug' => 'fotografi',
            'icon' => 'camera',
            'description' => 'Dokumentasi foto pernikahan, engagement, dan candid ceremony.',
            'sort_order' => 5,
            'is_active' => true,
        ],
        [
            'name' => 'Videografi',
            'slug' => 'videografi',
            'icon' => 'video',
            'description' => 'Video cinematic, same-day edit, drone, dan dokumentasi pernikahan.',
            'sort_order' => 6,
            'is_active' => true,
        ],
        [
            'name' => 'Make Up & Hair',
            'slug' => 'mua',
            'icon' => 'paintbrush',
            'description' => 'Make up artist, hair do, dan tim kecantikan pengantin.',
            'sort_order' => 7,
            'is_active' => true,
        ],
        [
            'name' => 'Busana Pengantin',
            'slug' => 'busana',
            'icon' => 'tshirt',
            'description' => 'Gaun, kebaya, jas, dan busana adat pengantin.',
            'sort_order' => 8,
            'is_active' => true,
        ],
        [
            'name' => 'Entertainment',
            'slug' => 'entertainment',
            'icon' => 'music.note',
            'description' => 'Band, DJ, musik akustik, dance performance, dan hiburan acara.',
            'sort_order' => 9,
            'is_active' => true,
        ],
        [
            'name' => 'Wedding Organizer',
            'slug' => 'wedding-organizer',
            'icon' => 'calendar.badge.checkmark',
            'description' => 'Perencanaan, koordinasi, dan manajemen acara pernikahan end-to-end.',
            'sort_order' => 10,
            'is_active' => true,
        ],
        [
            'name' => 'MC & Pembawa Acara',
            'slug' => 'mc',
            'icon' => 'mic.fill',
            'description' => 'Master of ceremony, pembawa acara, dan tim protocol.',
            'sort_order' => 11,
            'is_active' => true,
        ],
        [
            'name' => 'Undangan & Stationery',
            'slug' => 'undangan',
            'icon' => 'envelope.open.fill',
            'description' => 'Undangan fisik, digital, save the date, dan stationery pernikahan.',
            'sort_order' => 12,
            'is_active' => true,
        ],
        [
            'name' => 'Souvenir & Hampers',
            'slug' => 'souvenir',
            'icon' => 'gift.fill',
            'description' => 'Souvenir tamu, hampers, gift box, dan merchandise pernikahan.',
            'sort_order' => 13,
            'is_active' => true,
        ],
        [
            'name' => 'Kue & Dessert',
            'slug' => 'kue',
            'icon' => 'birthday.cake.fill',
            'description' => 'Wedding cake, dessert table, kue basah, dan pastry booth.',
            'sort_order' => 14,
            'is_active' => true,
        ],
        [
            'name' => 'Cincin & Perhiasan',
            'slug' => 'perhiasan',
            'icon' => 'ring.circle.fill',
            'description' => 'Cincin nikah, perhiasan pengantin, dan aksesoris jewelry.',
            'sort_order' => 15,
            'is_active' => true,
        ],
        [
            'name' => 'Transportasi',
            'slug' => 'transportasi',
            'icon' => 'car.fill',
            'description' => 'Mobil pengantin, bus tamu, dan layanan antar-jemput acara.',
            'sort_order' => 16,
            'is_active' => true,
        ],
        [
            'name' => 'Akomodasi Tamu',
            'slug' => 'akomodasi',
            'icon' => 'bed.double.fill',
            'description' => 'Hotel, guest house, dan paket menginap untuk tamu pernikahan.',
            'sort_order' => 17,
            'is_active' => true,
        ],
        [
            'name' => 'Sound & Lighting',
            'slug' => 'sound-lighting',
            'icon' => 'speaker.wave.3.fill',
            'description' => 'Sound system, lighting production, LED, dan stage setup.',
            'sort_order' => 18,
            'is_active' => true,
        ],
        [
            'name' => 'Photo Booth',
            'slug' => 'photo-booth',
            'icon' => 'camera.viewfinder',
            'description' => 'Photo booth, 360 video booth, dan aktivitas interaktif tamu.',
            'sort_order' => 19,
            'is_active' => true,
        ],
        [
            'name' => 'Prewedding',
            'slug' => 'prewedding',
            'icon' => 'heart.text.square.fill',
            'description' => 'Paket prewedding, lokasi shoot, dan konsep foto/video prewedding.',
            'sort_order' => 20,
            'is_active' => true,
        ],
        [
            'name' => 'Honeymoon',
            'slug' => 'honeymoon',
            'icon' => 'airplane.departure',
            'description' => 'Paket travel, staycation, dan liburan honeymoon pasangan.',
            'sort_order' => 21,
            'is_active' => true,
        ],
        [
            'name' => 'Hantaran & Seserahan',
            'slug' => 'hantaran',
            'icon' => 'basket.fill',
            'description' => 'Hantaran lamaran, seserahan, dan dekorasi tradisi adat.',
            'sort_order' => 22,
            'is_active' => true,
        ],
        [
            'name' => 'Sewa Peralatan',
            'slug' => 'rental',
            'icon' => 'chair.lounge.fill',
            'description' => 'Sewa kursi, meja, tenda, generator, dan peralatan acara.',
            'sort_order' => 23,
            'is_active' => true,
        ],
        [
            'name' => 'Dokumen & Legal',
            'slug' => 'legal',
            'icon' => 'doc.text.fill',
            'description' => 'Pengurusan dokumen pernikahan, legalisasi, dan layanan administrasi.',
            'sort_order' => 24,
            'is_active' => true,
        ],
    ];

    public function run(): void
    {
        foreach (self::CATEGORIES as $category) {
            Category::query()->updateOrCreate(
                ['slug' => $category['slug']],
                $category,
            );
        }
    }
}
