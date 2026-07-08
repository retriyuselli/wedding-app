<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Wedding App Defaults
    |--------------------------------------------------------------------------
    |
    | Single source of truth for budget-related defaults shared by API & admin.
    |
    */

    'default_currency' => env('WEDDING_DEFAULT_CURRENCY', 'IDR'),

    'default_expense_category' => 'other',

    'default_category_icon' => 'ellipsis',

    'default_expense_status' => 'pending',

    'default_incoming_payment_status' => 'menunggu',

    'brand' => [
        'name' => 'Wedding App',
        'developer' => 'Makna Kreatif Indonesia',
        'website_url' => env('WEDDING_WEBSITE_URL', 'https://www.weddingapp.co.id'),
        'website_display' => env('WEDDING_WEBSITE_DISPLAY', 'www.weddingapp.co.id'),
        'contact_email' => env('WEDDING_CONTACT_EMAIL', 'info@weddingapp.co.id'),
        'support_email' => env('WEDDING_SUPPORT_EMAIL', 'support@weddingapp.co.id'),
    ],

];
