// Organic Products Routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/organic-products', [OrganicProductController::class, 'index']);
    Route::post('/organic-products', [OrganicProductController::class, 'store']);
    Route::get('/organic-products/{organicProduct}', [OrganicProductController::class, 'show']);
    Route::put('/organic-products/{organicProduct}', [OrganicProductController::class, 'update']);
    Route::delete('/organic-products/{organicProduct}', [OrganicProductController::class, 'destroy']);
    Route::post('/organic-products/upload-image', [OrganicProductController::class, 'uploadImage']);
}); 