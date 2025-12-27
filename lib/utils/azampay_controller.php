<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AzamPayController extends Controller
{
    /**
     * -------------------------------------------------
     * AzamPay Webhook Callback
     * -------------------------------------------------
     * This endpoint is called asynchronously by AzamPay
     * after the user approves or rejects the payment.
     *
     * IMPORTANT:
     * - Must always return HTTP 200
     * - Must not redirect
     * - Must not throw uncaught exceptions
     */
    public function handleCallback(Request $request)
    {
        try {
            // Log EVERYTHING for audit/debug (safe)
            Log::channel('single')->info('🔔 AZAMPAY CALLBACK RECEIVED', [
                'timestamp' => now()->toDateTimeString(),
                'method'    => $request->method(),
                'ip'        => $request->ip(),
                'headers'   => $request->headers->all(),
                'payload'   => $request->all(),
            ]);

            $payload = $request->all();

            /**
             * Accept both camelCase and snake_case
             * because providers are inconsistent
             */
            $externalId = $payload['external_id']
                ?? $payload['externalId']
                ?? null;

            $status = strtolower($payload['status'] ?? '');

            if (!$externalId || !$status) {
                Log::error('❌ Invalid AzamPay callback payload', $payload);

                // Always return 200 to avoid retries
                return response()->json(['success' => false], 200);
            }

            /**
             * Find subscription by external_id
             * This MUST have been saved during checkout initiation
             */
            $subscription = DB::table('subscriptions')
                ->where('external_id', $externalId)
                ->first();

            if (!$subscription) {
                Log::error('❌ Subscription not found for AzamPay callback', [
                    'external_id' => $externalId,
                ]);

                return response()->json(['success' => false], 200);
            }

            /**
             * Map AzamPay status → internal status
             */
            $newStatus = match ($status) {
                'success', 'completed' => 'active',
                'failed', 'rejected'   => 'failed',
                default                => 'pending',
            };

            /**
             * Update subscription
             */
            DB::table('subscriptions')
                ->where('id', $subscription->id)
                ->update([
                    'status'       => $newStatus,
                    'payment_date' => $newStatus === 'active' ? now() : null,
                    'updated_at'   => now(),
                ]);

            Log::channel('single')->info('✅ Subscription updated via AzamPay', [
                'subscription_id' => $subscription->id,
                'external_id'     => $externalId,
                'status'          => $newStatus,
            ]);

            // AzamPay REQUIREMENT: always return 200
            return response()->json(['success' => true], 200);

        } catch (\Throwable $e) {

            Log::channel('single')->error('🔥 AzamPay callback exception', [
                'error'   => $e->getMessage(),
                'trace'   => $e->getTraceAsString(),
                'payload' => $request->all(),
            ]);

            // Never expose errors to AzamPay
            return response()->json(['success' => false], 200);
        }
    }
}
