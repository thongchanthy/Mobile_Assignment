<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * 1. Method index: Display a listing of products.
     * Supports optional search (?search=...) and category filter (?category_id=...)
     */
    public function index(Request $request)
    {
        $query = Product::with('category')->where('isDeleted', 0);

        // Optional search by name or barcode
        if ($request->filled('search')) {
            $search = $request->query('search');
            $query->where(function ($q) use ($search) {
                $q->where('ProductName', 'like', "%{$search}%")
                  ->orWhere('Barcode', 'like', "%{$search}%");
            });
        }

        // Optional filter by category
        if ($request->filled('category_id')) {
            $query->where('CategoryID', $request->query('category_id'));
        }

        $products = $query->orderBy('ProductID', 'desc')->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Products retrieved successfully',
            'data' => $products
        ], 200);
    }

    /**
     * 2. Method store: Store a newly created product.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ProductName'  => 'required|string|max:100',
            'Description'  => 'nullable|string|max:255',
            'CategoryID'   => 'required|integer|exists:categories,category_id',
            'Barcode'      => 'nullable|string|max:255',
            'Expiredate'   => 'nullable|date',
            'Qty'          => 'nullable|integer|min:0',
            'UnitPriceIn'  => 'nullable|numeric|min:0',
            'UnitPriceOut' => 'nullable|numeric|min:0',
            'ProductImage' => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();
        $data['Qty'] = $data['Qty'] ?? 0;
        $data['UnitPriceIn'] = $data['UnitPriceIn'] ?? 0.00;
        $data['UnitPriceOut'] = $data['UnitPriceOut'] ?? 0.00;
        $data['isDeleted'] = 0;

        // Handle uploaded file from device (supports image_file, ProductImage, or image)
        $uploadedFile = $request->file('image_file') ?? $request->file('ProductImage') ?? $request->file('image');
        if ($uploadedFile) {
            $filename = time() . '_' . uniqid() . '.' . ($uploadedFile->getClientOriginalExtension() ?: 'jpg');
            $path = $uploadedFile->storeAs('products', $filename, 'public');
            $data['ProductImage'] = url('storage/' . $path);
        } elseif ($request->filled('ProductImage') && is_string($request->input('ProductImage'))) {
            $data['ProductImage'] = $request->input('ProductImage');
        }

        $product = Product::create($data);
        $product->load('category');

        return response()->json([
            'status' => 'success',
            'message' => 'Product created successfully',
            'data' => $product
        ], 201);
    }

    /**
     * 3. Method show: Display the specified product.
     */
    public function show(string $id)
    {
        $product = Product::with('category')->find($id);

        if (!$product || $product->isDeleted == 1) {
            return response()->json([
                'status' => 'error',
                'message' => 'Product not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Product found',
            'data' => $product
        ], 200);
    }

    /**
     * 4. Method update: Update the specified product.
     */
    public function update(Request $request, string $id)
    {
        $product = Product::find($id);

        if (!$product || $product->isDeleted == 1) {
            return response()->json([
                'status' => 'error',
                'message' => 'Product not found'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'ProductName'  => 'sometimes|required|string|max:100',
            'Description'  => 'nullable|string|max:255',
            'CategoryID'   => 'sometimes|required|integer|exists:categories,category_id',
            'Barcode'      => 'nullable|string|max:255',
            'Expiredate'   => 'nullable|date',
            'Qty'          => 'nullable|integer|min:0',
            'UnitPriceIn'  => 'nullable|numeric|min:0',
            'UnitPriceOut' => 'nullable|numeric|min:0',
            'ProductImage' => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();

        // Handle uploaded file from device
        $uploadedFile = $request->file('image_file') ?? $request->file('ProductImage') ?? $request->file('image');
        if ($uploadedFile) {
            $filename = time() . '_' . uniqid() . '.' . ($uploadedFile->getClientOriginalExtension() ?: 'jpg');
            $path = $uploadedFile->storeAs('products', $filename, 'public');
            $data['ProductImage'] = url('storage/' . $path);
        } elseif ($request->filled('ProductImage') && is_string($request->input('ProductImage'))) {
            $data['ProductImage'] = $request->input('ProductImage');
        }

        $product->update($data);
        $product->load('category');

        return response()->json([
            'status' => 'success',
            'message' => 'Product updated successfully',
            'data' => $product
        ], 200);
    }

    /**
     * 5. Method destroy: Remove or soft-delete the specified product.
     */
    public function destroy(Request $request, string $id)
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'status' => 'error',
                'message' => 'Product not found'
            ], 404);
        }

        // Check if hard delete requested via ?force=true
        if ($request->query('force') === 'true') {
            $product->delete();
        } else {
            // Soft delete by updating isDeleted column to 1
            $product->update(['isDeleted' => 1]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Product deleted successfully'
        ], 200);
    }
}
