<?php

namespace Database\Seeders;

use App\Models\Vendor;
use App\Models\VendorPackage;
use Illuminate\Database\Seeder;

class VendorPackageSeeder extends Seeder
{
    /**
     * @var array<string, list<array<string, mixed>>>
     */
    private const PACKAGES_BY_VENDOR = [
        'grand-ballroom' => [
            [
                'name' => 'Paket Intimate',
                'slug' => 'paket-intimate',
                'description' => 'Ballroom setup untuk 100–200 tamu dengan dekor standar.',
                'price' => 35000000,
                'price_type' => 'starting_from',
                'capacity_min' => 100,
                'capacity_max' => 200,
                'inclusions' => ['Sewa ballroom 6 jam', 'Sound system', 'Parking area', 'Tim floor manager'],
                'sort_order' => 1,
                'is_featured' => false,
            ],
            [
                'name' => 'Paket Premium',
                'slug' => 'paket-premium',
                'description' => 'Paket lamaran lengkap dengan vendor pilihan.',
                'price' => 65000000,
                'price_type' => 'starting_from',
                'capacity_min' => 100,
                'capacity_max' => 100,
                'facility_sections' => [
                    [
                        'title' => 'Dekorasi by Hj. Nila, Naraya, PPM 2',
                        'items' => ['Dekorasi lamaran dan meja kursi'],
                    ],
                    [
                        'title' => 'Catering 100 pax by Hj. Nila',
                        'items' => ['Menu Ayam, Ikan, daging'],
                    ],
                    [
                        'title' => 'Photographer lamaran by Lenza, ink, On Clay',
                        'items' => ['Photographer dan videographer lamaran'],
                    ],
                    [
                        'title' => 'MUA By Indah Asyaa, MakeUpXVini, Ciqarizka, yukipratiwi',
                        'items' => [
                            'MUA lamaran + Hijab do Calon Tunang Wanita',
                            'MUA 2 Mama Calon Tunang',
                        ],
                    ],
                    [
                        'title' => 'Lain-Lain',
                        'items' => [
                            'Hantaran 10 akrilik, 10 rotan by Bilbo, formysonhantaran',
                            '1 orang Profesional MC',
                            'Set Standart Sound system & Mic Wireless',
                            'Tenda standard 2 unit',
                            'Kursi & Sarung 50 Pcs',
                            'WO lamaran by Makna Wedding',
                        ],
                    ],
                ],
                'exclusions' => [
                    'Transportasi tamu undangan',
                    'Biaya parkir valet',
                    'Tip dan overtime di luar jam paket',
                ],
                'sort_order' => 2,
                'is_featured' => true,
            ],
            [
                'name' => 'Paket Grand Royal',
                'slug' => 'paket-grand-royal',
                'description' => 'Paket mewah untuk 500–1000 tamu dengan fasilitas lengkap.',
                'price' => 120000000,
                'price_type' => 'starting_from',
                'capacity_min' => 500,
                'capacity_max' => 1000,
                'inclusions' => ['Full venue 10 jam', 'Red carpet', 'Premium lighting', 'Dedicated event team'],
                'sort_order' => 3,
                'is_featured' => true,
            ],
        ],
        'lavisa-decoration' => [
            [
                'name' => 'Paket Minimalis',
                'slug' => 'paket-minimalis',
                'description' => 'Pelaminan minimalis dengan bunga segar dan backdrop sederhana.',
                'price' => 15000000,
                'price_type' => 'fixed',
                'inclusions' => ['Backdrop pelaminan', 'Standing flowers', 'Meja akad', 'Setup & teardown'],
                'sort_order' => 1,
            ],
            [
                'name' => 'Paket Rustic Garden',
                'slug' => 'paket-rustic-garden',
                'description' => 'Konsep rustic outdoor dengan arch dan dekor kayu.',
                'price' => 28000000,
                'price_type' => 'fixed',
                'inclusions' => ['Wooden arch', 'Garden aisle', 'Table styling 10 meja', 'Hanging lights'],
                'sort_order' => 2,
                'is_featured' => true,
            ],
        ],
        'dewa-photography' => [
            [
                'name' => 'Paket Akad & Resepsi',
                'slug' => 'paket-akad-resepsi',
                'description' => 'Dokumentasi full day akad hingga resepsi.',
                'price' => 8500000,
                'price_type' => 'fixed',
                'duration_hours' => 10,
                'inclusions' => ['2 fotografer', '300 edited photos', 'Online gallery', 'Flash drive'],
                'sort_order' => 1,
                'is_featured' => true,
            ],
            [
                'name' => 'Paket Prewedding',
                'slug' => 'paket-prewedding',
                'description' => 'Sesi prewedding 1 lokasi dengan 2 konsep.',
                'price' => 4500000,
                'price_type' => 'fixed',
                'duration_hours' => 6,
                'inclusions' => ['1 fotografer', '80 edited photos', '1 lokasi', '2 outfit'],
                'sort_order' => 2,
            ],
            [
                'name' => 'Paket Cinematic',
                'slug' => 'paket-cinematic',
                'description' => 'Foto + video cinematic dengan drone.',
                'price' => 18000000,
                'price_type' => 'starting_from',
                'duration_hours' => 12,
                'inclusions' => ['Foto & video', 'Drone footage', 'Same-day highlight', 'Full ceremony film'],
                'sort_order' => 3,
                'is_featured' => true,
            ],
        ],
        'srikandi-catering' => [
            [
                'name' => 'Paket Prasmanan 300 Pax',
                'slug' => 'prasmanan-300-pax',
                'description' => 'Menu prasmanan nusantara untuk 300 tamu.',
                'price' => 45000000,
                'price_type' => 'fixed',
                'capacity_min' => 250,
                'capacity_max' => 300,
                'inclusions' => ['12 menu utama', 'Minuman welcome drink', 'Tim waiters', 'Peralatan makan'],
                'sort_order' => 1,
            ],
            [
                'name' => 'Paket Buffet 500 Pax',
                'slug' => 'buffet-500-pax',
                'description' => 'Buffet premium dengan live cooking station.',
                'price' => 75000000,
                'price_type' => 'fixed',
                'capacity_min' => 400,
                'capacity_max' => 500,
                'inclusions' => ['15 menu', 'Live cooking', 'Dessert table', 'Coffee station'],
                'sort_order' => 2,
                'is_featured' => true,
            ],
        ],
        'glow-mua-studio' => [
            [
                'name' => 'Paket Pengantin',
                'slug' => 'paket-pengantin',
                'description' => 'Make up & hair do pengantin dengan trial.',
                'price' => 3500000,
                'price_type' => 'fixed',
                'duration_hours' => 4,
                'inclusions' => ['Trial 1x', 'Make up akad', 'Hair do', 'Touch up kit'],
                'sort_order' => 1,
                'is_featured' => true,
            ],
        ],
        'the-majestic-hall' => [
            [
                'name' => 'Silver Package',
                'slug' => 'silver-package',
                'description' => 'Venue + basic decoration untuk 150 tamu.',
                'price' => 55000000,
                'price_type' => 'starting_from',
                'capacity_min' => 100,
                'capacity_max' => 150,
                'inclusions' => ['Venue 6 jam', 'Basic decor', 'Sound system'],
                'sort_order' => 1,
            ],
            [
                'name' => 'Gold Package',
                'slug' => 'gold-package',
                'description' => 'Venue premium rooftop + ballroom untuk 300 tamu.',
                'price' => 95000000,
                'price_type' => 'starting_from',
                'capacity_min' => 200,
                'capacity_max' => 300,
                'inclusions' => ['Rooftop ceremony', 'Ballroom reception', 'Premium decor'],
                'sort_order' => 2,
                'is_featured' => true,
            ],
        ],
        'rasa-nusantara' => [
            [
                'name' => 'Paket Nasi Box 200 Pax',
                'slug' => 'nasi-box-200-pax',
                'description' => 'Nasi box premium untuk akad atau ngunduh mantu.',
                'price' => 18000000,
                'price_type' => 'fixed',
                'capacity_min' => 150,
                'capacity_max' => 200,
                'inclusions' => ['Nasi box premium', 'Snack', 'Delivery', 'Packaging'],
                'sort_order' => 1,
            ],
            [
                'name' => 'Paket Wedding Feast',
                'slug' => 'wedding-feast',
                'description' => 'Prasmanan lengkap dengan live station.',
                'price' => 52000000,
                'price_type' => 'starting_from',
                'capacity_min' => 300,
                'capacity_max' => 400,
                'inclusions' => ['14 menu', 'Live gorengan', 'Es campur bar', 'Tim SOP lengkap'],
                'sort_order' => 2,
                'is_featured' => true,
            ],
        ],
        'frame-story-studio' => [
            [
                'name' => 'Essential Photo',
                'slug' => 'essential-photo',
                'description' => 'Dokumentasi candid akad & resepsi.',
                'price' => 7000000,
                'price_type' => 'fixed',
                'duration_hours' => 8,
                'inclusions' => ['1 fotografer', '200 photos', 'Online gallery'],
                'sort_order' => 1,
            ],
            [
                'name' => 'Complete Story',
                'slug' => 'complete-story',
                'description' => 'Foto + video same-day edit.',
                'price' => 14000000,
                'price_type' => 'fixed',
                'duration_hours' => 10,
                'inclusions' => ['2 fotografer', '1 videographer', 'Same-day edit', '400 photos'],
                'sort_order' => 2,
                'is_featured' => true,
            ],
        ],
    ];

    public function run(): void
    {
        foreach (self::PACKAGES_BY_VENDOR as $vendorSlug => $packages) {
            $vendor = Vendor::query()->where('slug', $vendorSlug)->first();

            if ($vendor === null) {
                continue;
            }

            foreach ($packages as $package) {
                VendorPackage::query()->updateOrCreate(
                    [
                        'vendor_id' => $vendor->id,
                        'slug' => $package['slug'],
                    ],
                    [
                        'name' => $package['name'],
                        'description' => $package['description'],
                        'price' => $package['price'],
                        'price_type' => $package['price_type'],
                        'capacity_min' => $package['capacity_min'] ?? null,
                        'capacity_max' => $package['capacity_max'] ?? null,
                        'duration_hours' => $package['duration_hours'] ?? null,
                        'inclusions' => $package['inclusions'] ?? [],
                        'facility_sections' => self::resolveFacilitySections($package),
                        'exclusions' => $package['exclusions'] ?? null,
                        'is_active' => true,
                        'is_featured' => $package['is_featured'] ?? false,
                        'sort_order' => $package['sort_order'],
                    ],
                );
            }
        }
    }

    /**
     * @param  array<string, mixed>  $package
     * @return list<array{title: string, items: list<string>}>
     */
    private static function resolveFacilitySections(array $package): array
    {
        if (isset($package['facility_sections']) && is_array($package['facility_sections'])) {
            return $package['facility_sections'];
        }

        $inclusions = $package['inclusions'] ?? [];

        if ($inclusions === []) {
            return [];
        }

        return [
            [
                'title' => 'Fasilitas',
                'items' => $inclusions,
            ],
        ];
    }
}
