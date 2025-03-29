<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Transport extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'vehicle_location',
        'vehicle_type',
        'departure_time',
        'arrival_time',
        'price',
        'capacity',
        'is_temperature_controlled',
        'temperature_range',
        'supported_product_types',
        'driver_id',
        'driver_rating',
        'has_insurance',
        'insurance_details',
        'certifications',
        'amenities',
        'status',
        'image_url',
        'owner_name',
        'price_per_kg',
        'driver_name',
        'driver_phone',
    ];

    protected $casts = [
        'departure_time' => 'datetime',
        'arrival_time' => 'datetime',
        'amenities' => 'array',
        'price' => 'decimal:2',
        'capacity' => 'decimal:2',
        'temperature_range' => 'decimal:2',
        'supported_product_types' => 'array',
        'driver_rating' => 'decimal:2',
        'has_insurance' => 'boolean',
        'certifications' => 'array',
        'is_available' => 'boolean',
        'is_temperature_controlled' => 'boolean',
        'price_per_kg' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function bookings()
    {
        return $this->hasMany(TransportBooking::class);
    }

    public function driver()
    {
        return $this->belongsTo(User::class, 'driver_id');
    }
} 