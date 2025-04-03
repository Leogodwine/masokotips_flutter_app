<?php

namespace App\Http\Controllers;

use App\Models\OrganicProduct;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class OrganicProductController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $products = OrganicProduct::with('category')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'status' => 'success',
            'data' => $products
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'is_active' => 'boolean',
            'is_featured' => 'boolean',
            'category_id' => 'required|exists:categories,id',
            'certification' => 'nullable|string',
            'origin' => 'nullable|string',
            'harvest_date' => 'nullable|date',
            'storage_conditions' => 'nullable|string',
            'shelf_life' => 'nullable|string',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        $validated['slug'] = Str::slug($validated['name']);
        $validated['seller_id'] = auth()->id();
        $validated['is_active'] = $validated['is_active'] ?? true;
        $validated['is_featured'] = $validated['is_featured'] ?? false;

        $product = OrganicProduct::create($validated);

        // Handle image uploads
        if ($request->hasFile('images')) {
            $images = [];
            foreach ($request->file('images') as $image) {
                $path = $image->store('organic-products', 'public');
                $images[] = Storage::url($path);
            }
            $product->update(['images' => $images]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Product created successfully',
            'data' => $product->load('category')
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(OrganicProduct $organicProduct)
    {
        return response()->json([
            'status' => 'success',
            'data' => $organicProduct->load('category')
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, OrganicProduct $organicProduct)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|required|numeric|min:0',
            'stock' => 'sometimes|required|integer|min:0',
            'is_active' => 'boolean',
            'is_featured' => 'boolean',
            'category_id' => 'sometimes|required|exists:categories,id',
            'certification' => 'nullable|string',
            'origin' => 'nullable|string',
            'harvest_date' => 'nullable|date',
            'storage_conditions' => 'nullable|string',
            'shelf_life' => 'nullable|string',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if (isset($validated['name'])) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        // Handle image uploads
        if ($request->hasFile('images')) {
            $images = [];
            foreach ($request->file('images') as $image) {
                $path = $image->store('organic-products', 'public');
                $images[] = Storage::url($path);
            }
            $validated['images'] = $images;
        }

        $organicProduct->update($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Product updated successfully',
            'data' => $organicProduct->load('category')
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(OrganicProduct $organicProduct)
    {
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
            'message' => 'Product deleted successfully'
        ]);
    }

    /**
     * Upload a single image for an organic product.
     */
    public function uploadImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        $path = $request->file('image')->store('organic-products', 'public');
        $url = Storage::url($path);

        return response()->json([
            'status' => 'success',
            'message' => 'Image uploaded successfully',
            'data' => [
                'url' => $url
            ]
        ]);
    }
} 