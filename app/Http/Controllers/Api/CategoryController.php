<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Category\StoreCategoryRequest;
use App\Http\Requests\Category\UpdateCategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CategoryController extends Controller
{
    /**
     * Display a listing of the categories.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $categories = Category::query()
            ->when($request->boolean('only_active'), fn($query) => $query->active())
            ->when($request->boolean('only_parents'), fn($query) => $query->whereNull('parent_id'))
            ->when($request->boolean('with_children'), fn($query) => $query->with('children'))
            ->when($request->boolean('with_products_count'), fn($query) => $query->withCount('products'))
            ->orderBy('sort_order')
            ->get();

        return CategoryResource::collection($categories);
    }

    /**
     * Store a newly created category in storage.
     */
    public function store(StoreCategoryRequest $request): CategoryResource
    {
        $category = Category::create($request->validated());

        return new CategoryResource($category);
    }

    /**
     * Display the specified category.
     */
    public function show(Request $request, Category $category): CategoryResource
    {
        if ($request->boolean('with_children')) {
            $category->load('children');
        }
        
        if ($request->boolean('with_parent')) {
            $category->load('parent');
        }

        if ($request->boolean('with_products_count')) {
            $category->loadCount('products');
        }

        return new CategoryResource($category);
    }

    /**
     * Update the specified category in storage.
     */
    public function update(UpdateCategoryRequest $request, Category $category): CategoryResource
    {
        $category->update($request->validated());

        return new CategoryResource($category);
    }

    /**
     * Remove the specified category from storage.
     */
    public function destroy(Category $category): JsonResponse
    {
        // Check if category has products
        if ($category->products()->exists()) {
            return response()->json([
                'message' => 'Cannot delete category with associated products'
            ], 409);
        }

        $category->delete();

        return response()->json([
            'message' => 'Category deleted successfully'
        ]);
    }
} 