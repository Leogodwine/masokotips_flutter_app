// services/subscription_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../utils/logger.dart';
import '../models/checkout_status_result.dart';

class SubscriptionService {
  static String get _baseUrl => ApiConfig.baseUrl;

  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  // ---------------------------------------------------------------------------
  // COMMON HEADERS
  // ---------------------------------------------------------------------------
  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent': _userAgent,
    };

    if (auth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ---------------------------------------------------------------------------
  // SAFE JSON PARSER
  // ---------------------------------------------------------------------------
  Map<String, dynamic>? _safeJson(http.Response res) {
    Log.d('HTTP ${res.statusCode}');
    Log.d('HEADERS ${res.headers}');
    Log.d('BODY ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      Log.e('Server error: ${res.statusCode}');
      return null;
    }

    final contentType = res.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      Log.e('Invalid content-type: $contentType');
      return null;
    }

    return jsonDecode(res.body);
  }

  // ---------------------------------------------------------------------------
  // GET SUBSCRIPTION PACKAGES (PUBLIC)
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // GET USER SUBSCRIPTIONS (AUTH)
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // CREATE SUBSCRIPTION
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> createSubscription({
    required String subscriptionType,
    required String duration,
    required String paymentMethod,
    String? phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'subscription_type': subscriptionType,
          'duration': duration,
          'payment_method': paymentMethod,
          'phone': phone,
        }),
      );

      return _safeJson(res);
    } catch (e) {
      Log.e('Create subscription error', e);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK AZAMPAY STATUS
  // ---------------------------------------------------------------------------
  /// Check checkout status by external ID (transaction ID).
  /// This method is deprecated. Use checkSubscriptionStatus() instead.
  ///
  /// @param externalId The external transaction ID from AzamPay
  /// @return AzamPayCheckoutStatusResult with status information
  @Deprecated('Use checkSubscriptionStatus() instead')
  Future<AzamPayCheckoutStatusResult?> checkAzamPayCheckoutStatus(
      String externalId) async {
    try {
      // The deprecated method in AzamPayService now returns a deprecated status
      // Instead, we should use the subscription status endpoint
      // However, since we only have the externalId (transaction ID), we cannot
      // directly call checkSubscriptionStatus which requires subscriptionId
      //
      // For now, return a deprecated result to maintain API compatibility
      return AzamPayCheckoutStatusResult(
        success: false,
        isPaid: false,
        status: 'DEPRECATED',
        message:
            'This method is deprecated. Use checkSubscriptionStatus() with subscription ID instead.',
      );
    } catch (e) {
      Log.e('Checkout status failed', e);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK SUBSCRIPTION ACCESS
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // CHECK SUBSCRIPTION STATUS
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // TOKEN
  // ---------------------------------------------------------------------------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
