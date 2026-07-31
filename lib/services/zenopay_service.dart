import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../config/phone_countries.dart';
import '../utils/logger.dart';
import '../utils/api_response.dart';

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
  static const String _checkoutEndpoint = '/zenopay/checkout';


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

      if (res.statusCode != 200 && res.statusCode != 201) {
        final decoded = ApiResponse.decodeJson(res.body);
        return ZenoCheckoutResult(
          success: false,
          orderId: null,
          message: decoded?['message']?.toString() ??
              'Payment could not be started (${res.statusCode}).',
        );
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      Log.d('🟢 PARSED RESPONSE: $data');

      final nested = data['data'] as Map<String, dynamic>?;
      final orderId = (nested?['order_id'] ??
              data['orderId'] ??
              data['order_id'] ??
              data['externalId'])
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

  /// Normalize to E.164 (+...) for international numbers.
  /// Uses Tanzania (255) as default when a local number is entered without country code.
  static String formatPhoneNumber(String phone, {String defaultDialCode = '255', String? countryIso}) {
    if (countryIso != null) {
      final country = PhoneCountries.byIso(countryIso);
      final national = PhoneCountries.normalizeNational(phone);
      if (country.validateNational(national) == null) {
        return '+${country.composeE164(national)}';
      }
    }

    final raw = phone.trim();

    if (raw.startsWith('+')) {
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      return digits.isEmpty ? raw : '+$digits';
    }

    String p = raw.replaceAll(RegExp(r'\D'), '');

    if (p.startsWith('00') && p.length > 2) {
      return '+${p.substring(2)}';
    }

    if (p.length >= 11) {
      return '+$p';
    }

    if (p.startsWith('0') && p.length > 1) {
      return '+$defaultDialCode${p.substring(1)}';
    }

    if (p.isNotEmpty) {
      return '+$defaultDialCode$p';
    }

    return raw;
  }
}
