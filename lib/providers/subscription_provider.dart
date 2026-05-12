import 'package:flutter/foundation.dart';

import '../models/subscription.dart';
import '../models/azam_checkout_result.dart';
import '../models/subscription_status_result.dart';

import '../services/subscription_service.dart';
import '../services/azampay_service.dart';

import '../utils/logger.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  // Keep AzamPay service for backward compatibility (other screens still use it)
  final AzamPayService _azamPayService = AzamPayService();

  // STATE
  List<SubscriptionPackage>? _packages;
  List<Subscription>? _userSubscriptions;
  Map<String, Subscription>? _currentSubscriptions;

  bool _isLoading = false;
  String? _errorMessage;

  // GETTERS
  List<SubscriptionPackage>? get packages => _packages;
  List<Subscription>? get userSubscriptions => _userSubscriptions;
  Map<String, Subscription>? get currentSubscriptions => _currentSubscriptions;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasActiveSubscription => _currentSubscriptions?.isNotEmpty ?? false;

  bool hasActiveSubscriptionFor(String type) {
    return _currentSubscriptions?[type]?.isActive ?? false;
  }

  /* ============================================================
   | LOAD SUBSCRIPTION PACKAGES
   ============================================================ */
  Future<void> loadPackages() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _subscriptionService.getSubscriptionPackages();

      if (response != null && response['success'] == true) {
        _packages = (response['data'] as List)
            .map((p) => SubscriptionPackage.fromJson(p))
            .toList();
      } else {
        _setError(
            response?['message'] ?? 'Failed to load subscription packages');
      }
    } catch (e) {
      Log.e('Load packages error: $e');
      _setError('Connection error. Please try again.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /* ============================================================
   | LOAD USER SUBSCRIPTIONS
   ============================================================ */
  Future<void> loadUserSubscriptions() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _subscriptionService.getUserSubscriptions();

      if (response != null && response['success'] == true) {
        _userSubscriptions = (response['data'] as List)
            .map((s) => Subscription.fromJson(s))
            .toList();

        _currentSubscriptions = {};
        for (final s in _userSubscriptions!) {
          if (s.isActive) {
            _currentSubscriptions![s.subscriptionType] = s;
          }
        }
      } else {
        _setError(response?['message'] ?? 'Failed to load subscriptions');
      }
    } catch (e) {
      Log.e('Load user subscriptions error: $e');
      _setError('Connection error. Please try again.');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  bool needsSubscription(String? role) {
    if (role == null) return true;
    return !hasActiveSubscriptionFor(role);
  }

  /* ============================================================
   | CREATE SUBSCRIPTION
   ============================================================ */
  Future<Subscription?> createSubscription({
    required String subscriptionType,
    required String duration,
    required String paymentMethod,
    required String phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _subscriptionService.createSubscription(
        subscriptionType: subscriptionType,
        duration: duration,
        paymentMethod: paymentMethod, // 'azampay' OR 'zenopay'
        phone: phone,
      );

      if (response != null && response['success'] == true) {
        return Subscription.fromJson(response['data']);
      }

      _setError(response?['message'] ?? 'Failed to create subscription');
      return null;
    } catch (e) {
      Log.e('Create subscription error: $e');
      _setError('Connection error.');
      return null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Returns the active subscription for the user (optional type filter)
  Subscription? getUserSubscription({String? type}) {
    if (_currentSubscriptions == null || _currentSubscriptions!.isEmpty) {
      return null;
    }

    if (type != null) {
      return _currentSubscriptions![type];
    }

    // Return the first active subscription if type not specified
    return _currentSubscriptions!.values.first;
  }

  /// Returns the latest subscription for the user, regardless of status
  Subscription? getLatestSubscription() {
    if (_userSubscriptions == null || _userSubscriptions!.isEmpty) {
      return null;
    }

    // Sort by created_at descending and return first
    final sorted = List<Subscription>.from(_userSubscriptions!);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }

  /// Returns the latest subscription of a specific type
  Subscription? getLatestSubscriptionByType(String type) {
    if (_userSubscriptions == null || _userSubscriptions!.isEmpty) {
      return null;
    }

    final typeSubs =
        _userSubscriptions!.where((s) => s.subscriptionType == type).toList();
    if (typeSubs.isEmpty) return null;

    typeSubs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return typeSubs.first;
  }

  /* ============================================================
   | AZAMPAY CHECKOUT (KEEP FOR OLD SCREENS)
   ============================================================ */
  Future<AzamCheckoutResult?> startAzamPayCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
    required String provider, // AIRTEL/VODACOM/TIGO/HALOTEL
  }) async {
    try {
      return await _azamPayService.startCheckout(
        subscriptionId: subscriptionId,
        amount: amount,
        phone: phone,
        provider: provider,
      );
    } catch (e) {
      Log.e('AzamPay checkout start failed: $e');
      return null;
    }
  }

  /* ============================================================
   | ZENOPAY CHECKOUT (NEW)
   ============================================================ */
  Future<Map<String, dynamic>?> startZenopayCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
  }) async {
    try {
      final res = await _subscriptionService.startZenopayCheckout(
        subscriptionId: subscriptionId,
        amount: amount,
        phone: phone,
      );

      if (res == null) {
        return {'success': false, 'message': 'No response from server.'};
      }

      if (res['success'] == true) {
        final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};

        return {
          'success': true,
          'message': res['message'] ?? 'Request in progress...',
          'order_id': data['order_id'], // 🔥 FLATTENED
          'subscription_id': data['subscription_id'],
        };
      }

      return {
        'success': false,
        'message': res['message'] ?? 'Failed to initiate payment.',
      };
    } catch (e) {
      Log.e('Zenopay checkout start failed: $e');
      return {
        'success': false,
        'message': 'Connection error. Please try again.'
      };
    }
  }

  /* ============================================================
   | BACKWARD COMPAT: keep old method name if other screens call it
   ============================================================ */
  @Deprecated(
      'Use startAzamPayCheckout() for AzamPay or startZenopayCheckout() for Zenopay.')
  Future<dynamic> startCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
    String? provider,
    String paymentMethod = 'azampay',
  }) async {
    if (paymentMethod == 'zenopay') {
      return startZenopayCheckout(
        subscriptionId: subscriptionId,
        amount: amount,
        phone: phone,
      );
    }

    return startAzamPayCheckout(
      subscriptionId: subscriptionId,
      amount: amount,
      phone: phone,
      provider: provider ?? 'TIGO',
    );
  }

  Future<Map<String, dynamic>?> checkZenopayOrderStatus(String orderId) async {
    try {
      return await _subscriptionService.checkZenopayOrderStatus(orderId);
    } catch (e) {
      Log.e('Check Zenopay order status failed: $e');
      return null;
    }
  }

  /* ============================================================
   | CHECK SUBSCRIPTION STATUS (READ-ONLY)
   ============================================================ */
  Future<SubscriptionStatusResult?> checkSubscriptionStatus(
      int subscriptionId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final data =
          await _subscriptionService.checkSubscriptionStatus(subscriptionId);

      if (data == null || data['success'] != true) {
        _errorMessage = data?['message'] ?? 'Failed to check status';
        notifyListeners();
        return null;
      }

      // ✅ NEW API shape (your current Laravel):
      // { success, is_active, status, subscription, message }
      if (data.containsKey('status') && data.containsKey('is_active')) {
        return SubscriptionStatusResult.fromJson(data.cast<String, dynamic>());
      }

      // ✅ BACKWARD COMPAT (older shape):
      // { success, data: { subscription: {...} } }
      final subscriptionJson = data['data']?['subscription'];
      if (subscriptionJson is Map<String, dynamic>) {
        return SubscriptionStatusResult.fromJson({
          'success': true,
          'is_active': subscriptionJson['status'] == 'active' ||
              subscriptionJson['status'] == 'completed',
          'status': subscriptionJson['status'] ?? 'UNKNOWN',
          'message': data['message'],
          'subscription': subscriptionJson,
        });
      }

      _errorMessage = 'Subscription data missing from response';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'An error occurred while checking subscription status.';
      notifyListeners();
      return null;
    }
  }

  // For SubscriptionScreen compatibility
  Future<Map<String, dynamic>?> getSubscriptionPackages() async {
    return await _subscriptionService.getSubscriptionPackages();
  }

  /* ============================================================
   | HELPERS
   ============================================================ */
  void _setLoading(bool value) => _isLoading = value;
  void _setError(String value) => _errorMessage = value;
  void _clearError() => _errorMessage = null;

  void clearSubscriptions() {
    _userSubscriptions = null;
    _currentSubscriptions = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscriptions = null;
    _currentSubscriptions = null;
    super.dispose();
  }
}
