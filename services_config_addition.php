<?php

return [

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.mailgun.net'),
        'scheme' => 'https',
    ],

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    /* =========================================================================
    | AZAMPAY CONFIGURATION - ADD THIS SECTION
    ========================================================================== */
    'azampay' => [
        'client_id' => env('AZAMPAY_CLIENT_ID', ''),
        'client_secret' => env('AZAMPAY_CLIENT_SECRET', ''),
        'base_url' => env('AZAMPAY_BASE_URL', 'https://api.azampay.co.tz'),
        'webhook_url' => env('AZAMPAY_WEBHOOK_URL', 'https://masokotips.com/api/azampay/webhook'),
    ],

];