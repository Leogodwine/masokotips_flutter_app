<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class AzamPayController extends Controller
{
    /**
     * Handle AzamPay payment callback
     */
    public function handleCallback(Request $request)
    {
        try {
            Log::info('AzamPay Callback Received', [
                'payload' => $request->all(),
                'headers' => $request->headers->all(),
                'timestamp' => now()
            ]);

            // Get the callback data
            $data = $request->all();
            
            // Validate required fields
            if (!isset($data['external_id']) || !isset($data['status'])) {
                Log::error('Invalid AzamPay callback data', $data);
                return response()->json(['error' => 'Invalid callback data'], 400);
            }

            // Find the subscription by external ID
            $subscription = DB::table('subscriptions')
                ->where('external_id', $data['external_id'])
                ->first();

            if (!$subscription) {
                Log::error('Subscription not found for external ID', ['external_id' => $data['external_id']]);
                return response()->json(['error' => 'Subscription not found'], 404);
            }

            // Update subscription status based on payment result
            $updateData = [
                'status' => $this->mapAzamPayStatus($data['status']),
                'payment_reference' => $data['transaction_id'] ?? null,
                'payment_date' => now(),
                'updated_at' => now()
            ];

            // Add metadata
            $metadata = json_decode($subscription->metadata ?? '{}', true);
            $metadata['azampay_callback'] = $data;
            $metadata['callback_received_at'] = now()->toISOString();
            $updateData['metadata'] = json_encode($metadata);

            DB::table('subscriptions')
                ->where('id', $subscription->id)
                ->update($updateData);

            Log::info('Subscription updated via AzamPay callback', [
                'subscription_id' => $subscription->id,
                'external_id' => $data['external_id'],
                'status' => $updateData['status']
            ]);

            // Return success response
            return response()->json([
                'status' => 'success',
                'message' => 'Callback processed successfully'
            ]);

        } catch (\Exception $e) {
            Log::error('Error processing AzamPay callback', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'payload' => $request->all()
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Internal server error'
            ], 500);
        }
    }

    /**
     * Map AzamPay status to our subscription status
     */
    private function mapAzamPayStatus($azamPayStatus)
    {
        switch (strtolower($azamPayStatus)) {
            case 'success':
            case 'completed':
                return 'completed';
            case 'failed':
            case 'failed':
                return 'failed';
            case 'pending':
            case 'processing':
                return 'pending';
            default:
                return 'pending';
        }
    }

    /**
     * Get payment status for a transaction
     */
    public function getPaymentStatus($transactionId)
    {
        try {
            // This would typically call AzamPay API to check status
            // For now, return mock data
            
            Log::info('Checking AzamPay payment status', ['transaction_id' => $transactionId]);
            
            return response()->json([
                'success' => true,
                'status' => 'pending',
                'message' => 'Status check completed'
            ]);

        } catch (\Exception $e) {
            Log::error('Error checking payment status', [
                'transaction_id' => $transactionId,
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error checking payment status'
            ], 500);
        }
    }
}