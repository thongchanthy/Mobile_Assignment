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
