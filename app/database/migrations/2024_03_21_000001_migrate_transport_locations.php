<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up()
    {
        // Get all transports with from_location and to_location
        $transports = DB::table('transports')
            ->select('id', 'from_location', 'to_location')
            ->whereNotNull('from_location')
            ->orWhereNotNull('to_location')
            ->get();

        // Update each transport with the combined location
        foreach ($transports as $transport) {
            $vehicleLocation = '';
            
            if ($transport->from_location && $transport->to_location) {
                // If both locations exist, combine them
                $vehicleLocation = "{$transport->from_location} - {$transport->to_location}";
            } elseif ($transport->from_location) {
                // If only from_location exists, use it
                $vehicleLocation = $transport->from_location;
            } elseif ($transport->to_location) {
                // If only to_location exists, use it
                $vehicleLocation = $transport->to_location;
            }

            // Update the transport with the new vehicle_location
            DB::table('transports')
                ->where('id', $transport->id)
                ->update(['vehicle_location' => $vehicleLocation]);
        }
    }

    public function down()
    {
        // Since we're dropping the columns in the previous migration,
        // there's nothing to revert here
    }
}; 