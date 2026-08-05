<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Vendor;
use Illuminate\Database\Seeder;

class VendorSeeder extends Seeder
{
    /**
     * @var list<array<string, mixed>>
     */
    private const VENDORS = [
        [
            'category_slug' => 'venue',
            'name' => 'Grand Ballroom',
            'slug' => 'grand-ballroom',
            'description' => 'Ballroom mewah dengan kapasitas 500–1000 tamu, parkir luas, dan fasilitas indoor lengkap.',
            'province' => 'Sumatera Selatan',
            'city' => 'Palembang',
            'address' => 'Jl. Sudirman No. 88, Palembang',
            'phone' => '081234567801',
            'email' => 'info@grandballroom.id',
            'website' => 'https://grandballroom.id',
            'instagram' => '@grandballroom.plg',
            'is_verified' => true,
            'is_featured' => true,
            'is_active' => true,
            'sort_order' => 1,
        ],
        [
            'category_slug' => 'dekorasi',
            'name' => 'Lavisa Decoration',
            'slug' => 'lavisa-decoration',
            'description' => 'Spesialis dekorasi modern dan rustic dengan konsep custom untuk setiap pasangan.',
            'province' => 'Sumatera Selatan',
            'city' => 'Palembang',
            'address' => 'Jl. Demang Lebar Daun No. 12, Palembang',
            'phone' => '081234567802',
            'email' => 'hello@lavisadecor.id',
            'website' => null,
            'instagram' => '@lavisadecoration',
            'is_verified' => true,
            'is_featured' => true,
            'is_active' => true,
            'sort_order' => 2,
        ],
        [
            'category_slug' => 'fotografi',
            'name' => 'Dewa Photography',
            'slug' => 'dewa-photography',
            'description' => 'Dokumentasi prewedding cinematic dengan opsi drone dan same-day edit.',
            'province' => 'Sumatera Selatan',
            'city' => 'Palembang',
            'address' => 'Jl. Kapten A Rivai No. 45, Palembang',
            'phone' => '081234567803',
            'email' => 'studio@dewaphoto.id',
            'website' => 'https://dewaphoto.id',
            'instagram' => '@dewaphotography',
            'is_verified' => true,
            'is_featured' => true,
            'is_active' => true,
            'sort_order' => 3,
        ],
        [
            'category_slug' => 'catering',
            'name' => 'Srikandi Catering',
            'slug' => 'srikandi-catering',
            'description' => 'Catering prasmanan dan buffet halal untuk acara pernikahan skala kecil hingga besar.',
            'province' => 'Sumatera Selatan',
            'city' => 'Palembang',
            'address' => 'Jl. Kolonel H. Burlian No. 20, Palembang',
            'phone' => '081234567804',
            'email' => 'order@srikandicatering.id',
            'website' => null,
            'instagram' => '@srikandicatering',
            'is_verified' => true,
            'is_featured' => false,
            'is_active' => true,
            'sort_order' => 4,
        ],
        [
            'category_slug' => 'mua',
            'name' => 'Glow MUA Studio',
            'slug' => 'glow-mua-studio',
            'description' => 'Make up natural dan glam dengan layanan on-site untuk pengantin dan keluarga.',
            'province' => 'Sumatera Selatan',
            'city' => 'Palembang',
            'address' => 'Jl. Angkatan 45 No. 7, Palembang',
            'phone' => '081234567805',
            'email' => 'booking@glowmua.id',
            'website' => null,
            'instagram' => '@glowmuastudio',
            'is_verified' => false,
            'is_featured' => false,
            'is_active' => true,
            'sort_order' => 5,
        ],
        [
            'category_slug' => 'venue',
            'name' => 'The Majestic Hall',
            'slug' => 'the-majestic-hall',
            'description' => 'Venue premium di Jakarta Selatan dengan rooftop garden dan ballroom utama.',
            'province' => 'Daerah Khusus Ibukota Jakarta',
            'city' => 'Administrasi Jakarta Selatan',
            'address' => 'Jl. Gatot Subroto Kav. 22, Jakarta Selatan',
            'phone' => '081234567806',
            'email' => 'reservation@majestic-hall.id',
            'website' => 'https://majestic-hall.id',
            'instagram' => '@themajestic.hall',
            'is_verified' => true,
            'is_featured' => true,
            'is_active' => true,
            'sort_order' => 6,
        ],
        [
            'category_slug' => 'catering',
            'name' => 'Rasa Nusantara',
            'slug' => 'rasa-nusantara',
            'description' => 'Paket catering pernikahan dengan menu nusantara dan live cooking station.',
            'province' => 'Jawa Barat',
            'city' => 'Bandung',
            'address' => 'Jl. Dago No. 15, Bandung',
            'phone' => '081234567807',
            'email' => 'info@rasanusantara.id',
            'website' => null,
            'instagram' => '@rasanusantara',
            'is_verified' => true,
            'is_featured' => false,
            'is_active' => true,
            'sort_order' => 7,
        ],
        [
            'category_slug' => 'fotografi',
            'name' => 'Frame Story Studio',
            'slug' => 'frame-story-studio',
            'description' => 'Fotografi candid dan cinematic untuk akad hingga resepsi.',
            'province' => 'Jawa Timur',
            'city' => 'Surabaya',
            'address' => 'Jl. Raya Darmo No. 90, Surabaya',
            'phone' => '081234567808',
            'email' => 'hello@framestory.id',
            'website' => 'https://framestory.id',
            'instagram' => '@framestory.studio',
            'is_verified' => true,
            'is_featured' => false,
            'is_active' => true,
            'sort_order' => 8,
        ],
    ];

    public function run(): void
    {
        foreach (self::VENDORS as $vendor) {
            $category = Category::query()
                ->where('slug', $vendor['category_slug'])
                ->first();

            if ($category === null) {
                continue;
            }

            Vendor::query()->updateOrCreate(
                ['slug' => $vendor['slug']],
                [
                    'category_id' => $category->id,
                    'name' => $vendor['name'],
                    'description' => $vendor['description'],
                    'province' => $vendor['province'],
                    'city' => $vendor['city'],
                    'address' => $vendor['address'],
                    'phone' => $vendor['phone'],
                    'email' => $vendor['email'],
                    'website' => $vendor['website'],
                    'instagram' => $vendor['instagram'],
                    'is_verified' => $vendor['is_verified'],
                    'is_featured' => $vendor['is_featured'],
                    'is_active' => $vendor['is_active'],
                    'sort_order' => $vendor['sort_order'],
                ],
            );
        }
    }
}
