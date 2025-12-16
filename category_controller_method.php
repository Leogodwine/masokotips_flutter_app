<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CategoryController
{
    /**
     * Get main categories with their subcategories
     *
     * @return JsonResponse
     */
    public function mainCategories(): JsonResponse
    {
        try {
            // Get only main categories (categories without parent_id)
            $categories = Category::whereNull('parent_id')
                ->with(['subcategories' => function($query) {
                    $query->select('id', 'name', 'parent_id', 'icon');
                }])
                ->select('id', 'name', 'description', 'icon', 'image')
                ->get();
                
            // Format the response to include subcategories count
            $formattedCategories = $categories->map(function ($category) {
                return [
                    'id' => $category->id,
                    'name' => $category->name,
                    'description' => $category->description,
                    'icon' => $category->icon,
                    'image' => $category->image,
                    'subcategoriesCount' => $category->subcategories->count(),
                    'subcategories' => $category->subcategories->map(function ($sub) {
                        return [
                            'id' => $sub->id,
                            'name' => $sub->name,
                            'icon' => $sub->icon,
                        ];
                    }),
                ];
            });
            
            return response()->json([
                'success' => true,
                'data' => $formattedCategories
            ]);
            
        } catch (\Exception $e) {
            \Log::error('Error fetching main categories: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'message' => 'Error fetching main categories'
            ], 500);
        }
    }
}