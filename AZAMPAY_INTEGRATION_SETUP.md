# AzamPay Integration Setup Guide

## Current Issue
The AzamPay API authentication is failing because:
1. The API credentials in the code are placeholder/test values
2. The callback URL configuration needs to be set up correctly
3. Allowed URLs need to be configured in your AzamPay account

## Step-by-Step Setup

### 1. Get Your Real AzamPay Credentials
1. **Login to AzamPay Developer Portal**: https://portal.azampay.co.tz
2. **Go to API Credentials** section
3. **Copy your actual**:
   - Client ID
   - Client Secret (not the encoded version you have)

### 2. Configure Callback URL (LIVE SERVER)
In your AzamPay developer account, set the **Callback URL** to:
```
https://masokotips.com/api/azampay/callback
```

### 3. Configure Allowed URLs (LIVE SERVER)
Add these URLs to your "Allowed URLs" section in AzamPay:
```
https://masokotips.com
https://www.masokotips.com
```

### 4. Update Your Code
Replace the placeholder credentials in `lib/services/azampay_service.dart`:

**Current (INCORRECT)**:
```dart
static const String _clientId = '77ca8404-43f1-4802-b8ab-feeacf81ad93';
static const String _clientSecret = 'adsfa4irReEScsy+jeW/tV51+WwitvGn3AVlzMNxJV5ls85pKYoBh3Zaz9M+cIoEvOhCIu1PBa1HNZ0kjYOcosViuA3WOhz7Xj1ep5d+gOS43g4GPZVBSvxcyOUSLLi7iQzqsd773CaVZX7LY/lb+IjehHwdMZgO7LCNaSmLBVm9tD1nNMrPXKePGowJ2baAKSCIG415+qVP8laG/YTNeDnhsB0GnLJvlET5SMh2nWluDL5ZWIOzVy687DNDamt7VhDvjLGVFAcRAhv+IiezBRDu3wnGvJ+x2oUojGdUq+mugF78UKZzh0htdcNy/uUX/RlnyT8UJ4O363xG7VcOIjYvfir9AURSOwf3ojOcCIfNKnzyoQDHkV0z44zU7Mrpq5eAqB09gMYScQ1t867l8Oc0GulVBytAnO+6TIbq9acHBbHFVYsEOSX2jHUTcdGXIIla+7SrK1e3hi9cw4z0lNc/bZdEjhWHaGyHYrked6BUy0G6d6xV+duqz0H4ah23fMGbHrYCCydSQFqfVqUlHiWX0lUPtAW6MH0C/W6/YcoKMZoDDbgINRMok4+jkcaeYzSGU/9pGke1y5n++tqKdj/De7WUEEJN54rTAVEkuahVwtBSEKtIlwdPyVlsZGDhi/H3gpkvzwTnC0DKRmplZry7o6cyAV7Xid74SXDF3GA=';
```

**Replace with YOUR actual credentials**:
```dart
static const String _clientId = 'YOUR_ACTUAL_CLIENT_ID';
static const String _clientSecret = 'YOUR_ACTUAL_CLIENT_SECRET';
```

### 5. Backend Callback Handler
You need to create a backend endpoint to handle AzamPay callbacks. Add this to your Laravel backend:

```php
// routes/api.php
Route::post('/azampay/callback', [AzamPayController::class, 'handleCallback']);

// app/Http/Controllers/Api/AzamPayController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AzamPayController extends Controller
{
    public function handleCallback(Request $request)
    {
        Log::info('AzamPay Callback Received', $request->all());
        
        // Process the callback here
        // Update payment status based on the callback data
        
        return response()->json(['status' => 'success']);
    }
}
```

### 6. Test the Integration
1. Update the credentials with your real ones
2. Test with a small amount (e.g., 100 TZS) on your live server
3. Check the logs for any authentication errors
4. Verify callbacks are received on masokotips.com

## Important Notes

### Security
- **Never commit real credentials** to version control
- Use environment variables for credentials in production
- The client secret you have in the code looks like a test/placeholder value

### Domain Configuration
- **Always use your live server (masokotips.com)** for reliable testing
- Payment gateways require publicly accessible URLs for callbacks
- Localhost and ngrok are unreliable for production testing

### Service Codes
The service codes in the code look correct:
- M-Pesa: `MP2022`
- Tigo Pesa: `TG2022`
- Airtel Money: `AT2022`

### Common Issues
1. **401 Unauthorized**: Wrong credentials or domain not allowed
2. **403 Forbidden**: Domain not in allowed URLs list
3. **404 Not Found**: Wrong API endpoint
4. **Timeout**: Network or callback URL issues

## Testing on Live Server

### Recommended Approach
1. **Use masokotips.com** as your testing environment
2. **Deploy your backend** to the live server
3. **Configure AzamPay** to point to masokotips.com
4. **Test with real payments** (small amounts)

### Benefits of Live Server Testing
- ✅ Reliable callback handling
- ✅ Real payment processing
- ✅ Production-like environment
- ✅ No tunneling complexity

## Next Steps
1. Get your real AzamPay credentials
2. Configure the callback URL to masokotips.com
3. Update the code with your credentials
4. Deploy backend to live server
5. Test the integration on masokotips.com

This approach ensures reliable testing and a smooth transition to production.