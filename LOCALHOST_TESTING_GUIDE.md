# Localhost Testing Guide for AzamPay

## Testing with Localhost

### Step 1: Configure Your Backend
1. **Make sure your Laravel backend is running** on port 8000:
   ```bash
   cd ../../wamp64/www/masoko_tips_api
   php artisan serve --port=8000
   ```

2. **Copy the callback controller** from `lib/utils/azampay_controller.php` to:
   ```
   ../../wamp64/www/masoko_tips_api/app/Http/Controllers/Api/AzamPayController.php
   ```

3. **Add the route** to `routes/api.php`:
   ```php
   Route::post('/azampay/callback', [App\Http\Controllers\Api\AzamPayController::class, 'handleCallback']);
   ```

### Step 2: Configure AzamPay Account
1. **Login to**: https://portal.azampay.co.tz
2. **Set Callback URL** to:
   ```
   http://localhost:8000/api/azampay/callback
   ```
3. **Add Allowed URLs**:
   ```
   http://localhost:8000
   http://localhost:3000
   ```

### Step 3: Update Your Credentials
Replace the credentials in `lib/services/azampay_service.dart` with your real ones:

```dart
static const String _clientId = 'YOUR_ACTUAL_CLIENT_ID';
static const String _clientSecret = 'YOUR_ACTUAL_CLIENT_SECRET';
```

### Step 4: Test the Integration

#### What to Expect:

**If it works (AzamPay allows localhost)**:
- ✅ Payment initiation will succeed
- ✅ Token generation will work
- ✅ You'll see callback logs in your Laravel log file

**If it doesn't work (most common)**:
- ❌ You'll get callback timeout errors
- ❌ Payment will fail because AzamPay can't reach localhost
- ❌ You'll see errors like "Failed to fetch" or callback timeouts

### Step 5: Check Laravel Logs
Watch your Laravel logs to see if callbacks are received:
```bash
tail -f ../../wamp64/www/masoko_tips_api/storage/logs/laravel.log
```

### Troubleshooting

#### If localhost doesn't work (most likely scenario):

1. **Quick Alternative - ngrok** (2 minutes setup):
   ```bash
   # Download ngrok from https://ngrok.com
   ngrok http 8000
   ```
   Use the https URL ngrok provides as your callback URL.

2. **Update AzamPay configuration**:
   - Callback URL: `https://abc123.ngrok.io/api/azampay/callback`
   - Allowed URLs: Add the ngrok URL to your allowed URLs list

### Success Indicators

You'll know it's working when:
- ✅ No more "Failed to fetch" errors
- ✅ Payment initiation returns success
- ✅ Laravel logs show "AzamPay Callback Received"
- ✅ Payment status updates correctly in your database

### Next Steps

1. **Try localhost first** - it might work for testing
2. **If it fails, use ngrok** - more reliable for development
3. **For production** - use your actual domain (masokotips.com)

The nice thing about this approach is that if localhost works, you save time. If it doesn't, you have a clear fallback with ngrok.