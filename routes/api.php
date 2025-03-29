<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\RecipeController;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ServiceController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\Api\TransportController;

/*
|--------------------------------------------------------------------------
| Authentication Routes
|--------------------------------------------------------------------------
*/
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
    
    // Protected Auth Routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/verify-email/{id}/{hash}', [AuthController::class, 'verifyEmail'])
            ->name('verification.verify');
        Route::post('/email/verification-notification', [AuthController::class, 'resendVerificationEmail'])
            ->middleware('throttle:6,1')
            ->name('verification.send');
    });
});

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
// Categories
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{category}', [CategoryController::class, 'show']);

// Products
Route::get('/products/categories', [ProductController::class, 'categories']);
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/featured', [ProductController::class, 'featured']);
Route::get('/products/{product}', [ProductController::class, 'show']);
Route::get('/products', [ProductController::class, 'sellerProducts']);

// Services
Route::get('/services/categories', [ServiceController::class, 'categories']);
Route::get('/services', [ServiceController::class, 'index']);
Route::get('/services/{service}', [ServiceController::class, 'show']);

// Reviews
Route::get('/reviews/product/{product}', [ReviewController::class, 'productReviews']);
Route::get('/reviews/service/{service}', [ReviewController::class, 'serviceReviews']);

/*
|--------------------------------------------------------------------------
| Protected Routes
|--------------------------------------------------------------------------
*/
Route::middleware(['auth:sanctum'])->group(function () {
    // User Profile
    Route::get('/user', [UserController::class, 'profile']);
    Route::put('/user/profile', [UserController::class, 'updateProfile']);
    Route::post('/user/avatar', [UserController::class, 'updateAvatar']);
    Route::put('/user/password', [UserController::class, 'updatePassword']);

    // Admin Routes
    Route::middleware(['role:admin'])->prefix('admin')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::get('/users/{user}', [UserController::class, 'show']);
        Route::put('/users/{user}/roles', [UserController::class, 'updateRoles']);
        Route::put('/users/{user}/status', [UserController::class, 'updateStatus']);
    });

    // Seller Routes
    Route::middleware(['role:seller'])->prefix('seller')->group(function () {
        Route::get('/products', [ProductController::class, 'sellerProducts']);
        Route::post('/products', [ProductController::class, 'store']);
        Route::put('/products/{product}', [ProductController::class, 'update']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);
        Route::get('/orders', [OrderController::class, 'sellerOrders']);
        Route::post('/products/upload-image', [ProductController::class, 'uploadImage']);
    });

    // Service Provider Routes
    Route::middleware(['role:service_provider'])->prefix('services')->group(function () {
        Route::get('/my-services', [ServiceController::class, 'providerServices']);
        Route::post('/', [ServiceController::class, 'store']);
        Route::put('/{service}', [ServiceController::class, 'update']);
        Route::delete('/{service}', [ServiceController::class, 'destroy']);
        Route::get('/bookings', [BookingController::class, 'providerBookings']);
    });

    // Buyer Routes
    Route::middleware(['role:buyer'])->prefix('buyer')->group(function () {
        Route::get('/orders', [OrderController::class, 'buyerOrders']);
        Route::post('/orders', [OrderController::class, 'store']);
        Route::get('/favorites', [FavoriteController::class, 'index']);
        Route::post('/favorites', [FavoriteController::class, 'toggle']);
    });

    // Reviews
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::put('/reviews/{review}', [ReviewController::class, 'update']);
    Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);

    // Protected Category Routes (admin/seller only)
    Route::middleware(['role:admin,seller'])->group(function () {
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::put('/categories/{category}', [CategoryController::class, 'update']);
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);
    });

    // Recipe Routes
    Route::prefix('recipes')->group(function () {
        Route::get('/', [RecipeController::class, 'index']);
        Route::post('/', [RecipeController::class, 'store']);
        Route::get('/{id}', [RecipeController::class, 'show']);
        Route::put('/{id}', [RecipeController::class, 'update']);
        Route::delete('/{id}', [RecipeController::class, 'destroy']);
        Route::post('/{id}/reviews', [ReviewController::class, 'store']);
    });

    // Transport Routes
    Route::apiResource('transports', TransportController::class);
    Route::post('transports/{id}/image', [TransportController::class, 'uploadImage']);
});