import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/api_response.dart';
import '../utils/logger.dart';

class CardPaymentService {
  static String get _base => ApiConfig.baseUrl;

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return ApiConfig.getHeaders(token);
  }

  /// Initiate card checkout — returns { payment_link, tx_ref }
  Future<Map<String, dynamic>?> startCardCheckout({
    required int subscriptionId,
    required int amount,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/zenopay/card/checkout'),
        headers: {
          ...await _headers(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subscription_id': subscriptionId,
          'amount': amount,
        }),
      );

      if (ApiResponse.looksLikeSecurityChallenge(res.body)) return null;
      return ApiResponse.decodeJson(res.body);
    } catch (e) {
      Log.e('CardPaymentService.startCardCheckout', e);
      return null;
    }
  }

  /// Poll subscription status after webview returns
  Future<Map<String, dynamic>?> checkCardStatus(int subscriptionId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/zenopay/card/status/$subscriptionId'),
        headers: await _headers(),
      );

      if (ApiResponse.looksLikeSecurityChallenge(res.body)) return null;
      return ApiResponse.decodeJson(res.body);
    } catch (e) {
      Log.e('CardPaymentService.checkCardStatus', e);
      return null;
    }
  }
}
