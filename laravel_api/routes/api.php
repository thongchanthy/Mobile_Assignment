<?php

use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application.
| These routes are loaded by bootstrap/app.php and assigned to the "api"
| middleware group.
|
*/

// Category API Routes (index, store, show, update, destroy)
Route::apiResource('categories', CategoryController::class);
Route::post('categories/{id}', [CategoryController::class, 'update']);

// Product API Routes (index, store, show, update, destroy)
Route::apiResource('products', ProductController::class);
Route::post('products/{id}', [ProductController::class, 'update']);

// Secure & CORS-enabled storage image route
Route::get('storage/{folder}/{filename}', function ($folder, $filename) {
    $path = storage_path('app/public/' . $folder . '/' . $filename);
    if (!file_exists($path)) {
        abort(404, 'Image not found');
    }
    $mime = mime_content_type($path) ?: 'image/jpeg';
    return response()->file($path, [
        'Content-Type' => $mime,
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
        'Cross-Origin-Resource-Policy' => 'cross-origin',
        'Cache-Control' => 'public, max-age=86400',
    ]);
})->where('filename', '.*');

