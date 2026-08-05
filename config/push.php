<?php

return [

    'driver' => env('PUSH_DRIVER', 'log'),

    'apns' => [
        'key_id' => env('APNS_KEY_ID'),
        'team_id' => env('APNS_TEAM_ID'),
        'bundle_id' => env('APNS_BUNDLE_ID', 'com.weddingapp.ios'),
        'private_key' => env('APNS_PRIVATE_KEY'),
        'production' => (bool) env('APNS_PRODUCTION', false),
    ],

];
