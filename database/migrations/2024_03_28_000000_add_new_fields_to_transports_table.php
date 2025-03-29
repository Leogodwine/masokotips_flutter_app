<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('transports', function (Blueprint $table) {
            // Remove available_seats as we're using capacity instead
            $table->dropColumn('available_seats');
            
            // Add new fields
            $table->decimal('capacity', 10, 2)->after('price');
            $table->boolean('is_temperature_controlled')->default(false)->after('capacity');
            $table->decimal('temperature_range', 5, 2)->nullable()->after('is_temperature_controlled');
            $table->json('supported_product_types')->nullable()->after('temperature_range');
            $table->foreignId('driver_id')->nullable()->after('supported_product_types')->constrained('users');
            $table->decimal('driver_rating', 3, 2)->nullable()->after('driver_id');
            $table->boolean('has_insurance')->default(false)->after('driver_rating');
            $table->text('insurance_details')->nullable()->after('has_insurance');
            $table->json('certifications')->nullable()->after('insurance_details');
            $table->boolean('is_available')->default(true)->after('certifications');
            $table->string('owner_name')->after('is_available');
            $table->decimal('price_per_kg', 10, 2)->nullable()->after('owner_name');
            $table->string('driver_name')->after('price_per_kg');
            $table->string('driver_phone')->after('driver_name');
        });
    }

    public function down()
    {
        Schema::table('transports', function (Blueprint $table) {
            // Remove all added columns
            $table->dropColumn([
                'capacity',
                'is_temperature_controlled',
                'temperature_range',
                'supported_product_types',
                'driver_id',
                'driver_rating',
                'has_insurance',
                'insurance_details',
                'certifications',
                'is_available',
                'owner_name',
                'price_per_kg',
                'driver_name',
                'driver_phone'
            ]);
            
            // Restore available_seats
            $table->integer('available_seats')->after('price');
        });
    }
}; 