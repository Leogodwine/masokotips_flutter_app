// services/azampay_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import '../models/azam_checkout_result.dart';
import '../models/checkout_status_result.dart';

class AzamPayService {
  static const String _backendBaseUrl = 'https://masokotips.com/api';

  // Backend endpoints (MATCH YOUR LARAVEL ROUTES)
  static const String _checkoutEndpoint = '/azampay/checkout/initiate';
  static const String _statusEndpoint = '/azampay/checkout/status';

  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  // ---------------------------------------------------------------------------
  // START CHECKOUT
  // ---------------------------------------------------------------------------
  Future<AzamCheckoutResult> startSubscriptionCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
    String? email,
    String currency = 'TZS',
  }) async {
    final uri = Uri.parse('$_backendBaseUrl$_checkoutEndpoint');

    final formattedPhone = formatPhoneNumber(phone);
    final token = await _getAuthToken();

    final payload = {
      'subscription_id': subscriptionId,
      'amount': amount,
      'currency': currency,
      'phone': formattedPhone,
      if (email != null) 'email': email,
    };

    Log.i(
        '💡 AzamPay checkout → subscription=$subscriptionId, amount=$amount, phone=$formattedPhone');
    Log.d('🔵 INIT CHECKOUT PAYLOAD: $payload');

    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ✅ REQUIRED
          'User-Agent': _userAgent,
        },
        body: jsonEncode(payload),
      );

      Log.d('🟡 INIT CHECKOUT RESPONSE: ${res.statusCode} | ${res.body}');

      final data = jsonDecode(res.body);

      return AzamCheckoutResult.fromJson(data);
    } catch (e) {
      Log.e('❌ Checkout Init Exception: $e');

      return AzamCheckoutResult(
        success: false,
        checkoutUrl: '',
        transactionId: '',
        message: 'Unable to start payment. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK CHECKOUT STATUS
  // ---------------------------------------------------------------------------
  Future<AzamPayCheckoutStatusResult> checkCheckoutStatus(
    String transactionId,
  ) async {
    final uri = Uri.parse('$_backendBaseUrl$_statusEndpoint/$transactionId');

    final token = await _getAuthToken();

    Log.d('🔵 CHECK STATUS: $uri');

    try {
      final res = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'User-Agent': _userAgent,
        },
      );

      Log.d('🟡 STATUS RESPONSE: ${res.statusCode} | ${res.body}');

      final data = jsonDecode(res.body);
      return AzamPayCheckoutStatusResult.fromJson(data);
    } catch (e) {
      Log.e('❌ Status Check Exception: $e');

      return AzamPayCheckoutStatusResult(
        success: false,
        message: 'Unable to check payment status.',
        status: 'UNKNOWN',
        isPaid: false,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Convert TZ numbers to E.164 (+255...)
  static String formatPhoneNumber(String phone) {
    String p = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (p.startsWith('255')) return '+$p';
    if (p.startsWith('0')) return '+255${p.substring(1)}';
    if (p.length == 9 && p.startsWith('7')) return '+255$p';

    return '+255$p';
  }
}
