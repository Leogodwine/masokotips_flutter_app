import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../utils/api_response.dart';
import '../utils/logger.dart';

class SubscriptionService {
  static String get _baseUrl => ApiConfig.baseUrl;

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final token = auth ? await _getToken() : null;
    return ApiConfig.getHeaders(token);
  }

  /// Parse HTTP response to JSON.
  /// For error responses (4xx / 5xx) we still return the decoded body so
  /// callers can surface the real error message to the user instead of a
  /// generic "no response" message.
  Map<String, dynamic>? _safeJson(http.Response res) {
    Log.d('HTTP ${res.statusCode}');
    Log.d('BODY ${res.body}');

    if (ApiResponse.looksLikeSecurityChallenge(res.body)) {
      Log.e('Security challenge returned instead of JSON');
      return null;
    }

    final contentType = res.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json') ||
        res.body.trimLeft().startsWith('{') ||
        res.body.trimLeft().startsWith('[');

    if (!isJson) {
      Log.e('Invalid content-type: $contentType (status ${res.statusCode})');
      if (res.statusCode != 200 && res.statusCode != 201) {
        return {'success': false, 'message': 'Server error (${res.statusCode})'};
      }
      return null;
    }

    final decoded = ApiResponse.decodeJson(res.body);

    if (res.statusCode != 200 && res.statusCode != 201) {
      Log.e('Server error ${res.statusCode}: ${res.body}');
      if (decoded != null) {
        // Ensure success flag is false so callers handle it as an error.
        return {'success': false, ...decoded};
      }
      return {'success': false, 'message': 'Server error (${res.statusCode})'};
    }

    return decoded;
  }

  Future<Map<String, dynamic>?> getSubscriptionPackages() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/subscriptions/packages'),
        headers: await _headers(),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Error fetching packages', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserSubscriptions() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/subscriptions/my-subscriptions'),
        headers: await _headers(auth: true),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Error fetching user subscriptions', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> createSubscription({
    required String subscriptionType,
    required String duration,
    required String paymentMethod,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{
        'subscription_type': subscriptionType,
        'duration': duration,
        'payment_method': paymentMethod,
      };
      // Only include phone when it has a real value — card payments don't need it
      if (phone != null && phone.trim().isNotEmpty) {
        body['phone'] = phone;
      }
      final res = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: await _headers(auth: true),
        body: jsonEncode(body),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Create subscription error', e);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 🚀 START ZENOPAY CHECKOUT (AUTH)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> startZenopayCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/zenopay/checkout'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'subscription_id': subscriptionId,
          'amount': amount,
          'phone': phone,
        }),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Start Zenopay checkout error', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkZenopayOrderStatus(String orderId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/zenopay/status/$orderId'),
        headers: await _headers(auth: true),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Zenopay order status error', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkSubscriptionAccess(String type) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/subscriptions/check-access/$type'),
        headers: await _headers(auth: true),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Check subscription access error', e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkSubscriptionStatus(
      int subscriptionId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/subscriptions/status/$subscriptionId'),
        headers: await _headers(auth: true),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Check subscription status error', e);
      return null;
    }
  }

  /// Cancel a stuck pending/pending_checkout subscription so the user can retry.
  Future<Map<String, dynamic>?> cancelPendingSubscription(
      int subscriptionId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/zenopay/subscription/$subscriptionId/cancel'),
        headers: await _headers(auth: true),
      );
      return _safeJson(res);
    } catch (e) {
      Log.e('Cancel pending subscription error', e);
      return null;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
