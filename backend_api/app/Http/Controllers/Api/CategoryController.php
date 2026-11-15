<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoryController extends Controller
{
    /**
     * 1. Method index: Display a listing of categories.
     */
    public function index()
    {
        $categories = Category::all();
        return response()->json([
            'status' => 'success',
            'message' => 'Categories retrieved successfully',
            'data' => $categories
        ], 200);
    }

    /**
     * 2. Method store: Store a newly created category.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'category_name' => 'required|string|max:50',
            'description'   => 'nullable|string|max:255',
            'image'         => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();

        // Handle file upload if provided
        $imageFile = $request->file('image') ?? $request->file('image_file');
        if ($imageFile) {
            $filename = time() . '_' . uniqid() . '.' . ($imageFile->getClientOriginalExtension() ?: 'jpg');
            $path = $imageFile->storeAs('categories', $filename, 'public');
            $data['image'] = url('api/storage/' . $path);
        } elseif ($request->filled('image') && is_string($request->input('image'))) {
            $data['image'] = $request->input('image');
        }

        $category = Category::create($data);

        return response()->json([
            'status' => 'success',
            'message' => 'Category created successfully',
            'data' => $category
        ], 201);
    }

    /**
     * 3. Method show: Display the specified category.
     */
    public function show(string $id)
    {
        $category = Category::with('products')->find($id);

        if (!$category) {
            return response()->json([
                'status' => 'error',
                'message' => 'Category not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Category found',
            'data' => $category
        ], 200);
    }

    /**
     * 4. Method update: Update the specified category.
     */
    public function update(Request $request, string $id)
    {
        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'status' => 'error',
                'message' => 'Category not found'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'category_name' => 'sometimes|required|string|max:50',
            'description'   => 'nullable|string|max:255',
            'image'         => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();

        $imageFile = $request->file('image') ?? $request->file('image_file');
        if ($imageFile) {
            $filename = time() . '_' . uniqid() . '.' . ($imageFile->getClientOriginalExtension() ?: 'jpg');
            $path = $imageFile->storeAs('categories', $filename, 'public');
            $data['image'] = url('api/storage/' . $path);
        } elseif ($request->filled('image') && is_string($request->input('image'))) {
            $data['image'] = $request->input('image');
        }

        $category->update($data);

        return response()->json([
            'status' => 'success',
            'message' => 'Category updated successfully',
            'data' => $category
        ], 200);
    }

    /**
     * 5. Method destroy: Remove the specified category.
     */
    public function destroy(string $id)
    {
        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'status' => 'error',
                'message' => 'Category not found'
            ], 404);
        }

        $category->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Category deleted successfully'
        ], 200);
    }
}
