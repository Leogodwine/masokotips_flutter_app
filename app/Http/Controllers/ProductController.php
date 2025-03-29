<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    /**
     * Upload a product image
     */
    public function uploadImage(Request $request)
    {
        try {
            $request->validate([
                'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
            ]);

            if (!$request->hasFile('image')) {
                return response()->json([
                    'message' => 'No image file provided'
                ], 400);
            }

            $file = $request->file('image');
            $path = $file->store('products', 'public');
            
            if (!$path) {
                throw new \Exception('Failed to store the image');
            }

            return response()->json([
                'url' => Storage::disk('public')->url($path),
                'message' => 'Image uploaded successfully'
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            \Log::error('Image upload failed: ' . $e->getMessage());
            return response()->json([
                'message' => 'Failed to upload image',
                'error' => $e->getMessage()
            ], 500);
        }
    }
} 