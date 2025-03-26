# Laravel Backend Fixes for Masoko Tips API

This guide provides step-by-step instructions to fix your Laravel backend issues related to product management and user roles.

## 1. Fix the ProductController@store Method

Your `store` method in `ProductController.php` is already correctly implemented. Make sure it has these key features:

- Validation for required fields
- Creating a slug from the product name
- Using the authenticated user's ID for the product
- Proper response with success message and product data

## 2. Fix Role Middleware

Your `CheckRole` middleware is already properly set up in `app/Http/Middleware/CheckRole.php` to:

- Check if the user is authenticated
- Check if the user's role matches the required role
- Return appropriate error responses with clear messages

## 3. Ensure Middleware is Registered

Your middleware is properly registered in `app/Http/Kernel.php`:

```php
protected $middlewareAliases = [
    // Other middleware...
    'role' => \App\Http\Middleware\CheckRole::class,
];

protected $routeMiddleware = [
    // Other middleware...
    'role' => \App\Http\Middleware\CheckRole::class,
];
```

## 4. Check API Routes

Your API routes in `routes/api.php` are correctly set up with:

```php
// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/user', [UserController::class, 'profile']);
    
    // Seller routes with role middleware
    Route::middleware('role:seller')->group(function () {
        Route::get('/seller/products', [ProductController::class, 'sellerProducts']);
        Route::post('/seller/products', [ProductController::class, 'store']);
        Route::post('/seller/products/{product}', [ProductController::class, 'update']);
        Route::post('/seller/products/{product}/delete', [ProductController::class, 'destroy']);
    });
});
```

## 5. Fix User Model's Role Handling

Your `User` model already implements a `hasRole` method:

```php
/**
 * Check if user has a specific role
 */
public function hasRole(string $role): bool
{
    return $this->role === $role;
}
```

## 6. Debug the API

Add this debug logging to your `store` method in `ProductController.php`:

```php
Log::info('Product creation attempt', [
    'user' => auth()->user()->name,
    'role' => auth()->user()->role,
    'data' => $request->all()
]);
```

## 7. Add a Test Seller Account

If you don't have a seller account, create one in your database:

```php
// Run this in tinker or a seeder
use App\Models\User;
use Illuminate\Support\Facades\Hash;

User::create([
    'name' => 'Test Seller',
    'email' => 'seller@example.com',
    'password' => Hash::make('password'),
    'role' => 'seller',
]);
```

## 8. Verify Database Schema

Make sure your database tables have the correct structure:

- `users` table has a `role` column that stores the user's role as a string
- `products` table has all the required columns (name, description, price, etc.)
- `categories` table exists and contains the category records

## 9. Frontend Configuration

Your Flutter app is already configured to:

- Use mock data by default in developer settings
- Include proper auth headers in API requests
- Handle API errors gracefully
- Show meaningful error messages

## Troubleshooting

If you're still having issues:

1. Check Laravel logs at `storage/logs/laravel.log`
2. Verify that a user with role 'seller' can successfully create products
3. Test your API endpoints with Postman or another API testing tool
4. Use the Flutter app's developer settings to toggle between mock data and real API
5. Check that your Laravel Sanctum setup is correct for handling authentication

By following these steps, you should be able to resolve the issues with your Laravel backend and get product management working properly. 