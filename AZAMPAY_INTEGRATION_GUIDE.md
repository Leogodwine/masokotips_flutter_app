# AzamPay Integration Guide for Masoko Tips App

## Overview

This guide documents the complete integration of AzamPay for mobile money payments in the Masoko Tips subscription system. The integration allows users to pay for subscriptions using M-Pesa, Tigo Pesa, and Airtel Money through AzamPay's API.

## Architecture

### Components Created/Modified

1. **Models** (`lib/models/azampay.dart`)
   - `AzamPayToken`: Handles authentication tokens
   - `AzamPayPaymentRequest`: Payment initiation requests
   - `AzamPayPaymentResponse`: Payment responses
   - `AzamPayTransactionStatus`: Transaction status tracking

2. **Service** (`lib/services/azampay_service.dart`)
   - Token generation and caching
   - Payment initiation
   - Status checking
   - Phone number formatting
   - Service code mapping

3. **Subscription Service Updates** (`lib/services/subscription_service.dart`)
   - Added AzamPay payment methods
   - Backend integration for transaction tracking
   - Status synchronization

4. **Provider Updates** (`lib/providers/subscription_provider.dart`)
   - AzamPay payment methods
   - State management for payment flow

5. **New Payment Screen** (`lib/screens/subscription/azampay_payment_screen.dart`)
   - Real-time payment status checking
   - Animated status indicators
   - Transaction ID display and copy

6. **Subscription Screen Updates** (`lib/screens/subscription/subscription_screen.dart`)
   - AzamPay payment method routing
   - Updated payment method labels

## Payment Flow

### 1. User Selection
- User selects subscription plan and payment method
- Payment methods now show "(AzamPay)" suffix for clarity

### 2. Payment Initiation
- System creates subscription in backend
- Initiates AzamPay payment with:
  - Formatted phone number
  - Amount in TZS
  - Service code (MP2022, TG2022, AT2022)
  - Unique external ID for tracking

### 3. User Experience
- User receives payment prompt on their phone
- Real-time status checking every 5 seconds
- Animated indicators for pending payments
- Success/failure dialogs

### 4. Backend Integration
- Transaction data saved to backend for tracking
- Status updates synchronized between AzamPay and backend
- Subscription activated on successful payment

## Configuration

### AzamPay Credentials
Update `lib/services/azampay_service.dart` with your actual credentials:

```dart
static const String _clientId = 'your_actual_azampay_client_id';
static const String _clientSecret = 'your_actual_azampay_client_secret';
```

### API Endpoints
Update base URL if needed:
```dart
static const String _baseUrl = 'https://api.azampay.co.tz';
```

## Features

### Security
- Token-based authentication
- Automatic token refresh
- Secure phone number formatting
- Transaction ID tracking

### User Experience
- Real-time payment status
- Animated status indicators
- Clear error messages
- Transaction ID copy functionality
- Automatic status checking

### Developer Experience
- Comprehensive logging
- Error handling
- Type-safe models
- Provider state management

## Usage

### For Users
1. Select subscription plan
2. Choose payment method (M-Pesa, Tigo Pesa, or Airtel Money)
3. Enter phone number and amount
4. Complete payment on phone when prompted
5. Wait for automatic verification

### For Developers
1. Import AzamPay models: `import '../../models/azampay.dart';`
2. Use AzamPay service: `AzamPayService().initiatePayment(request)`
3. Monitor payment status: `checkAzamPayPaymentStatus(transactionId)`

## Error Handling

### Common Scenarios
- **Network errors**: Automatic retry with user notification
- **Invalid phone number**: Formatting validation
- **Payment timeout**: Manual status check option
- **Failed payments**: Clear error messages with retry options

### Logging
All AzamPay operations are logged using the app's logger:
- `Log.d()` for debug information
- `Log.e()` for errors
- `Log.w()` for warnings

## Testing

### Manual Testing Checklist
- [ ] Token generation works
- [ ] Payment initiation succeeds
- [ ] Status checking functions
- [ ] Error handling works
- [ ] UI updates correctly
- [ ] Backend synchronization works

### Test Cases
1. **Successful Payment**
   - Initiate payment
   - Complete on phone
   - Verify success status
   - Check subscription activation

2. **Failed Payment**
   - Cancel payment on phone
   - Verify failure status
   - Check error messages

3. **Network Issues**
   - Test offline scenarios
   - Verify error handling
   - Check retry functionality

## Backend Requirements

The backend should implement these endpoints:

### POST /subscriptions/azampay-transaction
Save AzamPay transaction details
```json
{
  "subscription_id": 123,
  "azampay_transaction_id": "tx_123",
  "azampay_payment_id": "pay_123",
  "external_id": "ext_123",
  "amount": 1000.0,
  "currency": "TZS",
  "provider": "mpesa",
  "status": "initiated"
}
```

### PUT /subscriptions/azampay-transaction/{transactionId}
Update payment status
```json
{
  "status": "SUCCESS",
  "reason": "Payment completed",
  "completed_at": "2023-12-10T10:00:00Z"
}
```

### GET /subscriptions/azampay-transaction/{transactionId}
Retrieve transaction details

## Future Enhancements

### Potential Improvements
1. **Webhook Integration**: Real-time status updates
2. **Payment History**: Transaction history screen
3. **Refund Handling**: Automated refund process
4. **Multi-currency**: Support for other currencies
5. **QR Code**: Alternative payment methods

### Monitoring
1. **Analytics**: Payment success rates
2. **Alerts**: Failed payment notifications
3. **Reporting**: Transaction summaries

## Support

### Troubleshooting
1. **Token Issues**: Check credentials and network
2. **Payment Failures**: Verify phone number and balance
3. **Status Updates**: Check network connectivity
4. **UI Issues**: Clear app cache and restart

### Debug Information
- Check logs for detailed error information
- Verify API responses in network tab
- Test with known working credentials

## Security Considerations

1. **Credentials**: Store in environment variables
2. **Token Storage**: Secure token caching
3. **Phone Numbers**: Validate and format properly
4. **Transaction IDs**: Unique and secure
5. **API Calls**: Use HTTPS only

## Version History

- **v1.0**: Initial AzamPay integration
- Supports M-Pesa, Tigo Pesa, Airtel Money
- Real-time status checking
- Complete payment flow

## Contact

For technical support or questions about this integration, refer to:
- AzamPay Developer Documentation: https://developerdocs.azampay.co.tz/
- App development team
- Backend API documentation