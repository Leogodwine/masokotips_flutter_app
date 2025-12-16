# Live Server Testing Setup for AzamPay

## Why Use Live Server for Testing

✅ **Reliable**: Payment gateways require publicly accessible URLs for callbacks
✅ **Production-like**: Test in the same environment you'll use for production
✅ **No tunneling complexity**: No need for ngrok or other tunneling services
✅ **Real payment processing**: Test with actual payment flows

## Step-by-Step Setup

### 1. Get Your AzamPay Credentials
1. **Login to**: https://portal.azampay.co.tz
2. **Navigate to**: API Credentials section
3. **Copy your actual**:
   - Client ID
   - Client Secret

### 2. Configure AzamPay Account
1. **Set Callback URL** to:
   ```
   https://masokotips.com/api/azampay/callback
   ```
2. **Add Allowed URLs**:
   ```
   https://masokotips.com
   https://www.masokotips.com
   ```

### 3. Update Your Flutter Code
In `lib/services/azampay_service.dart`, replace the placeholder credentials:

**Current (WRONG)**:
```dart
static const String _clientId = 'YOUR_CLIENT_ID_HERE';
static const String _clientSecret = 'YOUR_CLIENT_SECRET_HERE';
```

**Replace with your real credentials**:
```dart
static const String _clientId = 'your_actual_client_id';
static const String _clientSecret = 'your_actual_client_secret';
```

### 4. Set Up Backend Callback Handler
1. **Copy** `lib/utils/azampay_controller.php` to:
   ```
   ../../wamp64/www/masoko_tips_api/app/Http/Controllers/Api/AzamPayController.php
   ```

2. **Add this route** to `routes/api.php`:
   ```php
   Route::post('/azampay/callback', [App\Http\Controllers\Api\AzamPayController::class, 'handleCallback']);
   ```

3. **Deploy your backend** to masokotips.com

### 5. Test the Integration
1. **Build and run** your Flutter app
2. **Navigate to subscription** screen
3. **Select a mobile money option** (M-Pesa, Tigo, Airtel)
4. **Enter test amount** (e.g., 100 TZS)
5. **Complete payment** and verify callback is received

## Expected Results

### ✅ Success Indicators
- No more "Failed to fetch" authentication errors
- Payment initiation returns success
- AzamPay payment prompt appears on your phone
- Callback logs appear in your Laravel logs on masokotips.com
- Payment status updates correctly in the database

### ❌ If Issues Occur
- Check Laravel logs: `tail -f storage/logs/laravel.log`
- Verify callback URL is publicly accessible
- Ensure credentials are correct in AzamPay portal
- Confirm allowed URLs include masokotips.com

## Testing Strategy

### Phase 1: Small Amount Testing
- Start with very small amounts (100 TZS)
- Test all three mobile money providers
- Verify callback handling works

### Phase 2: Integration Testing
- Test complete subscription workflow
- Verify payment status updates
- Test error handling scenarios

### Phase 3: Production Ready
- Test with actual subscription amounts
- Verify all features work correctly
- Monitor for any edge cases

## Benefits of This Approach

1. **Reliable Testing**: No network or tunneling issues
2. **Real Environment**: Same as production setup
3. **Faster Development**: No complex local setup required
4. **Easy Debugging**: Clear logs and error tracking
5. **Smooth Transition**: Easy move to production

This approach ensures your AzamPay integration works reliably from day one.