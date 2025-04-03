<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategoriesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Fruits',
                'slug' => 'fruits',
                'description' => 'Fresh organic fruits',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Vegetables',
                'slug' => 'vegetables',
                'description' => 'Fresh organic vegetables',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Grains',
                'slug' => 'grains',
                'description' => 'Organic grains and cereals',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Dairy',
                'slug' => 'dairy',
                'description' => 'Organic dairy products',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Meat',
                'slug' => 'meat',
                'description' => 'Organic meat products',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Beverages',
                'slug' => 'beverages',
                'description' => 'Organic beverages and drinks',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Snacks',
                'slug' => 'snacks',
                'description' => 'Organic snacks and treats',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Spices',
                'slug' => 'spices',
                'description' => 'Organic herbs and spices',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Oils',
                'slug' => 'oils',
                'description' => 'Organic cooking oils',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Honey',
                'slug' => 'honey',
                'description' => 'Organic honey and bee products',
                'parent_id' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('categories')->insert($categories);
    }
} 