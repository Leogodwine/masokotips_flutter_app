<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    protected $user;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create a test user
        $this->user = User::factory()->create([
            'role' => 'seller'
        ]);
    }

    public function test_can_create_category()
    {
        $response = $this->actingAs($this->user)
            ->postJson('/api/categories', [
                'name' => 'Electronics',
                'description' => 'All electronic devices and accessories',
                'is_active' => true,
                'sort_order' => 1
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'name' => 'Electronics',
                    'slug' => 'electronics',
                    'description' => 'All electronic devices and accessories',
                    'is_active' => true,
                    'sort_order' => 1
                ]
            ]);
    }

    public function test_can_list_categories()
    {
        // Create a test category first
        $this->actingAs($this->user)
            ->postJson('/api/categories', [
                'name' => 'Electronics',
                'description' => 'All electronic devices',
                'is_active' => true
            ]);

        $response = $this->getJson('/api/categories');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'slug',
                        'description',
                        'is_active'
                    ]
                ]
            ]);
    }

    public function test_can_show_category()
    {
        $category = $this->actingAs($this->user)
            ->postJson('/api/categories', [
                'name' => 'Electronics',
                'description' => 'All electronic devices',
                'is_active' => true
            ])
            ->json('data');

        $response = $this->getJson("/api/categories/{$category['id']}");

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'name' => 'Electronics',
                    'slug' => 'electronics'
                ]
            ]);
    }

    public function test_can_update_category()
    {
        $category = $this->actingAs($this->user)
            ->postJson('/api/categories', [
                'name' => 'Electronics',
                'description' => 'All electronic devices',
                'is_active' => true
            ])
            ->json('data');

        $response = $this->actingAs($this->user)
            ->putJson("/api/categories/{$category['id']}", [
                'name' => 'Updated Electronics',
                'description' => 'Updated description'
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'name' => 'Updated Electronics',
                    'description' => 'Updated description'
                ]
            ]);
    }

    public function test_can_delete_category()
    {
        $category = $this->actingAs($this->user)
            ->postJson('/api/categories', [
                'name' => 'Electronics',
                'description' => 'All electronic devices',
                'is_active' => true
            ])
            ->json('data');

        $response = $this->actingAs($this->user)
            ->deleteJson("/api/categories/{$category['id']}");

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Category deleted successfully'
            ]);
    }
} 