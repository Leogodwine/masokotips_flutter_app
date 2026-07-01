import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/api_response.dart';
import '../utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZenopayCardService {
  static String get _base => ApiConfig.baseUrl;

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return ApiConfig.getHeaders(token);
  }

  /// Initiate a card checkout session.
  /// Returns { success, payment_link, tx_ref } on success.
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

      Log.d('Card checkout response: ${res.statusCode} ${res.body}');

      if (ApiResponse.looksLikeSecurityChallenge(res.body)) return null;
      return ApiResponse.decodeJson(res.body);
    } catch (e) {
      Log.e('ZenopayCardService.startCardCheckout', e);
      return null;
    }
  }

  /// Poll subscription status after webview returns.
  Future<Map<String, dynamic>?> checkCardStatus(int subscriptionId) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/zenopay/card/status/$subscriptionId'),
        headers: await _headers(),
      );
      if (ApiResponse.looksLikeSecurityChallenge(res.body)) return null;
      return ApiResponse.decodeJson(res.body);
    } catch (e) {
      Log.e('ZenopayCardService.checkCardStatus', e);
      return null;
    }
  }
}
