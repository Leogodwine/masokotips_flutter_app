import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../utils/logger.dart';

class ZenoCheckoutResult {
  final bool success;
  final String? orderId;
  final String? message;

  ZenoCheckoutResult({
    required this.success,
    required this.orderId,
    required this.message,
  });
}

class ZenoPayService {
  static String get _backendBaseUrl => ApiConfig.baseUrl;

  // MUST match Laravel route
  static const String _checkoutEndpoint = '/zenopay/checkout/initiate';


  // ---------------------------------------------------------------------------
  // START CHECKOUT
  // ---------------------------------------------------------------------------
  Future<ZenoCheckoutResult> startCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
    String? buyerName,
    String? buyerEmail,
  }) async {
    final uri = Uri.parse('$_backendBaseUrl$_checkoutEndpoint');
    final formattedPhone = formatPhoneNumber(phone);
    final token = await _getAuthToken();

    final payload = {
      'subscription_id': subscriptionId,
      'amount': amount,
      'phone': formattedPhone,
      if (buyerName != null && buyerName.trim().isNotEmpty)
        'buyer_name': buyerName.trim(),
      if (buyerEmail != null && buyerEmail.trim().isNotEmpty)
        'buyer_email': buyerEmail.trim(),
    };

    Log.i(
      'ZenoPay checkout → subscription=$subscriptionId, '
      'amount=$amount, phone=$formattedPhone',
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

      // backend should return: { success: true, orderId: "...", message: "...", status: "pending" }
      final orderId =
          (data['orderId'] ?? data['order_id'] ?? data['externalId'])
              ?.toString();

      return ZenoCheckoutResult(
        success: data['success'] == true,
        orderId: orderId,
        message: data['message']?.toString(),
      );
    } catch (e) {
      Log.e('❌ ZenoPay Checkout Init Exception: $e');

      return ZenoCheckoutResult(
        success: false,
        orderId: null,
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

  /// Keep same formatting you used for AzamPay: E.164 (+255...)
  static String formatPhoneNumber(String phone) {
    String p = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (p.startsWith('255')) return '+$p';
    if (p.startsWith('0')) return '+255${p.substring(1)}';
    if (p.length == 9 && p.startsWith('7')) return '+255$p';

    return '+255$p';
  }
}
