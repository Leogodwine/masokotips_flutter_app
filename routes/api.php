// Organic Products Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/organic-products', [OrganicProductController::class, 'index']);
    Route::post('/organic-products', [OrganicProductController::class, 'store']);
    Route::get('/organic-products/{organicProduct}', [OrganicProductController::class, 'show']);
    Route::put('/organic-products/{organicProduct}', [OrganicProductController::class, 'update']);
    Route::delete('/organic-products/{organicProduct}', [OrganicProductController::class, 'destroy']);
    Route::post('/organic-products/upload-image', [OrganicProductController::class, 'uploadImage']);
    
    // Service Routes
    Route::get('/services', [ServiceController::class, 'index']);
    Route::post('/services', [ServiceController::class, 'store']);
    Route::get('/services/{service}', [ServiceController::class, 'show']);
    Route::put('/services/{service}', [ServiceController::class, 'update']);
    Route::delete('/services/{service}', [ServiceController::class, 'destroy']);
    Route::post('/services/upload-image', [ServiceController::class, 'uploadImage']);
    Route::get('/my-services', [ServiceController::class, 'myServices']);
}); 

// Admin Routes
Route::prefix('admin')->group(function () {
    // Admin Authentication Routes
    Route::post('/verify', [AdminController::class, 'verify']);
    Route::post('/login', [AdminController::class, 'login']);
    Route::post('/register', [AdminController::class, 'register']);
    Route::post('/create', [AdminController::class, 'create']);
    
    // Protected Admin Routes
    Route::middleware(['auth:sanctum', 'admin'])->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard']);
        Route::get('/users', [AdminController::class, 'users']);
        Route::get('/services', [AdminController::class, 'services']);
        Route::get('/market-info', [AdminController::class, 'marketInfo']);
    });
}); 