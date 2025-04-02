<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\OrganicProduct;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class OrganicProductController extends Controller
{
    /**
     * Display a listing of organic products.
     */
    public function index()
    {
        $products = OrganicProduct::with(['seller', 'category'])
            ->where('is_active', true)
            ->latest()
            ->paginate(10);

        return response()->json([
            'status' => 'success',
            'data' => $products,
        ]);
    }

    /**
     * Store a newly created organic product.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            'is_active' => 'boolean',
            'is_featured' => 'boolean',
            'certification' => 'nullable|string|max:255',
            'origin' => 'nullable|string|max:255',
            'harvest_date' => 'nullable|date',
            'storage_conditions' => 'nullable|string|max:255',
            'shelf_life' => 'nullable|string|max:255',
            'images.*' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $product = new OrganicProduct($request->all());
            $product->seller_id = auth()->id();
            $product->slug = Str::slug($request->name);

            // Handle image upload
            if ($request->hasFile('images')) {
                $imageUrls = [];
                foreach ($request->file('images') as $image) {
                    $path = $image->store('organic-products', 'public');
                    $imageUrls[] = Storage::url($path);
                }
                $product->images = $imageUrls;
                $product->image_url = $imageUrls[0];
            }

            $product->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Organic product created successfully',
                'data' => $product->load(['seller', 'category']),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create organic product',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Display the specified organic product.
     */
    public function show(OrganicProduct $organicProduct)
    {
        return response()->json([
            'status' => 'success',
            'data' => $organicProduct->load(['seller', 'category']),
        ]);
    }

    /**
     * Update the specified organic product.
     */
    public function update(Request $request, OrganicProduct $organicProduct)
    {
        // Check if the user owns this product
        if ($organicProduct->seller_id !== auth()->id()) {
            return response()->json([
                'status' => 'error',
                'message' => 'You do not have permission to update this product',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            'is_active' => 'boolean',
            'is_featured' => 'boolean',
            'certification' => 'nullable|string|max:255',
            'origin' => 'nullable|string|max:255',
            'harvest_date' => 'nullable|date',
            'storage_conditions' => 'nullable|string|max:255',
            'shelf_life' => 'nullable|string|max:255',
            'images.*' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $organicProduct->fill($request->all());
            $organicProduct->slug = Str::slug($request->name);

            // Handle image upload
            if ($request->hasFile('images')) {
                $imageUrls = [];
                foreach ($request->file('images') as $image) {
                    $path = $image->store('organic-products', 'public');
                    $imageUrls[] = Storage::url($path);
                }
                $organicProduct->images = $imageUrls;
                $organicProduct->image_url = $imageUrls[0];
            }

            $organicProduct->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Organic product updated successfully',
                'data' => $organicProduct->load(['seller', 'category']),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update organic product',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified organic product.
     */
    public function destroy(OrganicProduct $organicProduct)
    {
        // Check if the user owns this product
        if ($organicProduct->seller_id !== auth()->id()) {
            return response()->json([
                'status' => 'error',
                'message' => 'You do not have permission to delete this product',
            ], 403);
        }

        try {
            // Delete associated images
            if ($organicProduct->images) {
                foreach ($organicProduct->images as $image) {
                    $path = str_replace('/storage/', '', $image);
                    Storage::disk('public')->delete($path);
                }
            }

            $organicProduct->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Organic product deleted successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to delete organic product',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Upload a single image for organic product.
     */
    public function uploadImage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $path = $request->file('image')->store('organic-products', 'public');
            $url = Storage::url($path);

            return response()->json([
                'status' => 'success',
                'message' => 'Image uploaded successfully',
                'url' => $url,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to upload image',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
} 