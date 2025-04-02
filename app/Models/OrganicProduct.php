<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class OrganicProduct extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'price',
        'stock',
        'image_url',
        'images',
        'is_active',
        'is_featured',
        'seller_id',
        'category_id',
        'certification',
        'origin',
        'harvest_date',
        'storage_conditions',
        'shelf_life',
    ];

    protected $casts = [
        'images' => 'array',
        'is_active' => 'boolean',
        'is_featured' => 'boolean',
        'price' => 'decimal:2',
        'harvest_date' => 'date',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($product) {
            if (empty($product->slug)) {
                $product->slug = Str::slug($product->name);
            }
        });

        static::updating(function ($product) {
            if ($product->isDirty('name')) {
                $product->slug = Str::slug($product->name);
            }
        });
    }

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function getFormattedPriceAttribute()
    {
        return number_format($this->price, 2);
    }

    public function getFormattedHarvestDateAttribute()
    {
        return $this->harvest_date ? $this->harvest_date->format('Y-m-d') : null;
    }

    public function toArray()
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,
            'price' => $this->price,
            'formatted_price' => $this->formatted_price,
            'stock' => $this->stock,
            'image_url' => $this->image_url,
            'images' => $this->images,
            'is_active' => $this->is_active,
            'is_featured' => $this->is_featured,
            'seller_id' => $this->seller_id,
            'category_id' => $this->category_id,
            'certification' => $this->certification,
            'origin' => $this->origin,
            'harvest_date' => $this->formatted_harvest_date,
            'storage_conditions' => $this->storage_conditions,
            'shelf_life' => $this->shelf_life,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'seller' => $this->seller,
            'category' => $this->category,
        ];
    }
} 