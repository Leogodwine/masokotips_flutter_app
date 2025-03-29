<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('transports', function (Blueprint $table) {
            $table->dropColumn(['from_location', 'to_location']);
            $table->string('vehicle_location')->after('description');
        });
    }

    public function down()
    {
        Schema::table('transports', function (Blueprint $table) {
            $table->string('from_location')->after('description');
            $table->string('to_location')->after('from_location');
            $table->dropColumn('vehicle_location');
        });
    }
}; 