<?php

namespace App\Http\Controllers;

use App\Models\Transport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use App\Http\Resources\TransportResource;

class TransportController extends Controller
{
    public function index()
    {
        $transports = Transport::with(['user', 'driver'])->get();
        return response()->json(['data' => $transports]);
    }

    public function show($id)
    {
        $transport = Transport::with(['user', 'driver'])->findOrFail($id);
        return response()->json(['data' => $transport]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'vehicle_location' => 'required|string',
            'vehicle_type' => 'required|string',
            'departure_time' => 'required|date',
            'arrival_time' => 'required|date|after:departure_time',
            'price' => 'required|numeric|min:0',
            'capacity' => 'required|numeric|min:0',
            'is_temperature_controlled' => 'required|boolean',
            'temperature_range' => 'nullable|numeric',
            'supported_product_types' => 'required|array',
            'driver_id' => 'nullable|exists:drivers,id',
            'driver_rating' => 'nullable|numeric|min:0|max:5',
            'has_insurance' => 'required|boolean',
            'insurance_details' => 'nullable|string',
            'certifications' => 'nullable|array',
            'amenities' => 'nullable|array',
            'status' => 'required|string|in:active,inactive',
            'image_url' => 'nullable|string',
            'owner_name' => 'required|string',
            'price_per_kg' => 'nullable|numeric|min:0',
            'driver_name' => 'required|string',
            'driver_phone' => 'required|string',
        ]);

        $transport = Transport::create($validated);

        return response()->json([
            'message' => 'Transport created successfully',
            'data' => new TransportResource($transport)
        ], 201);
    }

    public function update(Request $request, Transport $transport)
    {
        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'vehicle_location' => 'sometimes|required|string',
            'vehicle_type' => 'sometimes|required|string',
            'departure_time' => 'sometimes|required|date',
            'arrival_time' => 'sometimes|required|date|after:departure_time',
            'price' => 'sometimes|required|numeric|min:0',
            'capacity' => 'sometimes|required|numeric|min:0',
            'is_temperature_controlled' => 'sometimes|required|boolean',
            'temperature_range' => 'nullable|numeric',
            'supported_product_types' => 'sometimes|required|array',
            'driver_id' => 'nullable|exists:drivers,id',
            'driver_rating' => 'nullable|numeric|min:0|max:5',
            'has_insurance' => 'sometimes|required|boolean',
            'insurance_details' => 'nullable|string',
            'certifications' => 'nullable|array',
            'amenities' => 'nullable|array',
            'status' => 'sometimes|required|string|in:active,inactive',
            'image_url' => 'nullable|string',
            'owner_name' => 'sometimes|required|string',
            'price_per_kg' => 'nullable|numeric|min:0',
            'driver_name' => 'sometimes|required|string',
            'driver_phone' => 'sometimes|required|string',
        ]);

        $transport->update($validated);

        return response()->json([
            'message' => 'Transport updated successfully',
            'data' => new TransportResource($transport)
        ]);
    }

    public function destroy($id)
    {
        $transport = Transport::findOrFail($id);
        $transport->delete();
        return response()->json(null, 204);
    }

    public function uploadImage(Request $request, $id)
    {
        $transport = Transport::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($transport->image_url) {
            Storage::delete($transport->image_url);
        }

        $path = $request->file('image')->store('transports', 'public');
        $transport->update(['image_url' => $path]);

        return response()->json([
            'data' => [
                'image_url' => Storage::url($path)
            ]
        ]);
    }
} 