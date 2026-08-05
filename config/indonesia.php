<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Data Wilayah Indonesia (Provinsi → Kabupaten/Kota)
    |--------------------------------------------------------------------------
    |
    | Sumber: database/data/indonesia-regions.json (38 provinsi, ~514 kab/kota).
    | Gunakan App\Support\IndonesiaRegions untuk akses data ini.
    |
    | Catatan: Jangan pakai Enum PHP untuk daftar ini — datanya terlalu besar
    | dan lebih mudah dirawat sebagai config + JSON.
    |
    */

    'regions_file' => database_path('data/indonesia-regions.json'),

];
