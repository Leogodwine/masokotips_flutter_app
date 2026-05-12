// services/azampay_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../utils/logger.dart';
import '../models/azam_checkout_result.dart';

class AzamPayService {
  static String get _backendBaseUrl => ApiConfig.baseUrl;

  // MUST match Laravel route
  static const String _checkoutEndpoint = '/azampay/checkout/initiate';


  // ---------------------------------------------------------------------------
  // START CHECKOUT (AUTHORITATIVE)
  // ---------------------------------------------------------------------------
  Future<AzamCheckoutResult> startCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
    required String provider, // 🔑 REQUIRED (AIRTEL/VODACOM/TIGO/HALOTEL)
  }) async {
    final uri = Uri.parse('$_backendBaseUrl$_checkoutEndpoint');
    final formattedPhone = formatPhoneNumber(phone);
    final token = await _getAuthToken();

    final payload = {
      'subscription_id': subscriptionId,
      'amount': amount,
      'phone': formattedPhone,
      'service_provider': provider,
    };

    Log.i(
      'AzamPay checkout → subscription=$subscriptionId, '
      'amount=$amount, phone=$formattedPhone, service_provider=$provider',
    );
    Log.d('🔵 INIT CHECKOUT PAYLOAD: $payload');
    Log.d('🔗 REQUEST URL: $uri');

    try {
      final res = await http
          .post(
            uri,
            headers: ApiConfig.getHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      Log.d('🟡 INIT CHECKOUT RESPONSE: ${res.statusCode} | ${res.body}');

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      Log.d('🟢 PARSED RESPONSE: $data');

      return AzamCheckoutResult(
        success: data['success'] == true,
        externalId: data['externalId'],
        message: data['message'],
      );
    } catch (e) {
      Log.e('❌ Checkout Init Exception: $e');

      return AzamCheckoutResult(
        success: false,
        externalId: null,
        message: 'Unable to start payment. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      Log.w('⚠️ No authentication token found!');
    } else {
      Log.d(
        '🔑 Auth token found: ${token.substring(0, min(20, token.length))}...',
      );
    }

    return token;
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
