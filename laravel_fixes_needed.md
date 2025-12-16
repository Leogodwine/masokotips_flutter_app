# Laravel Backend Fixes Needed

## Fix 1: Add Missing main-categories Route

In your `routes/api.php` file, add this route AFTER line 266:

```php
/* =========================================================================
| MAIN CATEGORIES (Public) - ADD THIS ROUTE
=========================================================================== */
Route::get('/main-categories', [CategoryController::class, 'mainCategories']);
```

## Fix 2: Add AzamPay Configuration

Create or update `config/services.php` and add this section:

```php
<?php

return [
    // ... existing services ...

    'azampay' => [
        'client_id' => env('AZAMPAY_CLIENT_ID', ''),
        'client_secret' => env('AZAMPAY_CLIENT_SECRET', ''),
        'base_url' => env('AZAMPAY_BASE_URL', 'https://api.azampay.co.tz'),
        'webhook_url' => env('AZAMPAY_WEBHOOK_URL', 'https://masokotips.com/api/azampay/webhook'),
    ],
];
```

## Fix 3: Update .env file

Add these lines to your `.env` file:

```env
AZAMPAY_CLIENT_ID=your_actual_client_id
AZAMPAY_CLIENT_SECRET=your_actual_client_secret
AZAMPAY_BASE_URL=https://api.azampay.co.tz
AZAMPAY_WEBHOOK_URL=https://masokotips.com/api/azampay/webhook
```

## Fix 4: CategoryController Method

Make sure your `CategoryController` has a `mainCategories` method that returns only main categories (categories without a parent).

Example method to add to CategoryController:

```php
public function mainCategories()
{
    $categories = Category::where('parent_id', null)
        ->with('subcategories')
        ->get();
        
    return response()->json([
        'data' => $categories
    ]);
}
```

## After Adding These Fixes:

1. Clear Laravel cache: `php artisan config:clear`
2. Restart Laravel server: Stop and start `php artisan serve --port=8000`
3. Test: `curl http://localhost:8000/api/main-categories`