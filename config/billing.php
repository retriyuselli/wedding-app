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
        'wedding_pro_monthly',
    ],

    // Auto-renewable. Lifetime unlock stays in pro_product_ids with no expiry.
    'subscription_product_ids' => [
        'wedding_pro_monthly',
    ],

    'pro_required_message' => 'Fitur ini tersedia di Wedding Pro. Silakan upgrade untuk melanjutkan.',

    // Non-premium users can mark this many checklist tasks done before the Pro prompt.
    'free_checklist_done_limit' => 20,

    'checklist_free_limit_message' => 'Batas 20 tugas selesai untuk akun gratis sudah tercapai.',

    /*
    |--------------------------------------------------------------------------
    | Apple StoreKit verification
    |--------------------------------------------------------------------------
    */
    'apple_bundle_id' => env('APPLE_BUNDLE_ID', 'com.weddingapp.ios'),

    // Relative env values (e.g. storage/certs/...) are resolved from the project
    // root. Absolute paths are kept as-is. This avoids failures when the process
    // CWD is public/ (php artisan serve / php-fpm).
    'apple_root_ca_path' => (static function (): string {
        $configured = env('APPLE_ROOT_CA_PATH');

        if (! is_string($configured) || $configured === '') {
            return storage_path('certs/AppleRootCA-G3.pem');
        }

        if (
            str_starts_with($configured, DIRECTORY_SEPARATOR)
            || preg_match('/^[A-Za-z]:[\\\\\\/]/', $configured) === 1
        ) {
            return $configured;
        }

        return base_path($configured);
    })(),

    /*
     * NEVER enable in production. Allows decoding JWS without signature checks (tests only).
     */
    'apple_jws_verification_bypass' => (bool) env('APPLE_JWS_VERIFICATION_BYPASS', false),
];
