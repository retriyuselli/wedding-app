<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Wedding Pro product identifiers
    |--------------------------------------------------------------------------
    |
    | Must match App Store Connect / StoreKit Configuration product IDs.
    |
    */
    'pro_product_ids' => [
        'wedding_pro_unlock',
    ],

    'pro_required_message' => 'Fitur ini tersedia di Wedding Pro. Silakan upgrade untuk melanjutkan.',

    /*
    |--------------------------------------------------------------------------
    | Apple StoreKit verification
    |--------------------------------------------------------------------------
    */
    'apple_bundle_id' => env('APPLE_BUNDLE_ID', 'com.weddingapp.ios'),

    'apple_root_ca_path' => env(
        'APPLE_ROOT_CA_PATH',
        storage_path('certs/AppleRootCA-G3.pem'),
    ),

    /*
     * NEVER enable in production. Allows decoding JWS without signature checks (tests only).
     */
    'apple_jws_verification_bypass' => (bool) env('APPLE_JWS_VERIFICATION_BYPASS', false),
];
