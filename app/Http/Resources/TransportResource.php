<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TransportResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'vehicle_location' => $this->vehicle_location,
            'vehicle_type' => $this->vehicle_type,
            'departure_time' => $this->departure_time,
            'arrival_time' => $this->arrival_time,
            'price' => $this->price,
            'capacity' => $this->capacity,
            'is_temperature_controlled' => $this->is_temperature_controlled,
            'temperature_range' => $this->temperature_range,
            'supported_product_types' => $this->supported_product_types,
            'driver_id' => $this->driver_id,
            'driver_rating' => $this->driver_rating,
            'has_insurance' => $this->has_insurance,
            'insurance_details' => $this->insurance_details,
            'certifications' => $this->certifications,
            'amenities' => $this->amenities,
            'status' => $this->status,
            'image_url' => $this->image_url,
            'owner_name' => $this->owner_name,
            'price_per_kg' => $this->price_per_kg,
            'driver_name' => $this->driver_name,
            'driver_phone' => $this->driver_phone,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
} 