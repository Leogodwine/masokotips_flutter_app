<?php

namespace App\Http\Controllers;

use App\Models\Transport;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

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
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'from_location' => 'required|string|max:255',
            'to_location' => 'required|string|max:255',
            'vehicle_type' => 'required|string|max:255',
            'departure_time' => 'required|date',
            'arrival_time' => 'required|date|after:departure_time',
            'price' => 'required|numeric|min:0',
            'capacity' => 'required|numeric|min:0',
            'is_temperature_controlled' => 'required|boolean',
            'temperature_range' => 'nullable|numeric',
            'supported_product_types' => 'required|array',
            'driver_id' => 'nullable|exists:users,id',
            'driver_rating' => 'nullable|numeric|min:0|max:5',
            'has_insurance' => 'required|boolean',
            'insurance_details' => 'nullable|string',
            'certifications' => 'nullable|array',
            'amenities' => 'nullable|array',
            'status' => 'required|string|in:active,inactive',
            'image_url' => 'nullable|string',
            'owner_name' => 'required|string|max:255',
            'price_per_kg' => 'nullable|numeric|min:0',
            'driver_name' => 'required|string|max:255',
            'driver_phone' => 'required|string|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $transport = Transport::create($request->all());
        return response()->json(['data' => $transport], 201);
    }

    public function update(Request $request, $id)
    {
        $transport = Transport::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|string|max:255',
            'from_location' => 'sometimes|string|max:255',
            'to_location' => 'sometimes|string|max:255',
            'vehicle_type' => 'sometimes|string|max:255',
            'departure_time' => 'sometimes|date',
            'arrival_time' => 'sometimes|date|after:departure_time',
            'price' => 'sometimes|numeric|min:0',
            'capacity' => 'sometimes|numeric|min:0',
            'is_temperature_controlled' => 'sometimes|boolean',
            'temperature_range' => 'nullable|numeric',
            'supported_product_types' => 'sometimes|array',
            'driver_id' => 'nullable|exists:users,id',
            'driver_rating' => 'nullable|numeric|min:0|max:5',
            'has_insurance' => 'sometimes|boolean',
            'insurance_details' => 'nullable|string',
            'certifications' => 'nullable|array',
            'amenities' => 'nullable|array',
            'status' => 'sometimes|string|in:active,inactive',
            'image_url' => 'nullable|string',
            'owner_name' => 'sometimes|string|max:255',
            'price_per_kg' => 'nullable|numeric|min:0',
            'driver_name' => 'sometimes|string|max:255',
            'driver_phone' => 'sometimes|string|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $transport->update($request->all());
        return response()->json(['data' => $transport]);
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