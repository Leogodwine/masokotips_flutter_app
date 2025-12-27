import 'package:flutter/foundation.dart';

import '../models/subscription.dart';
import '../models/azam_checkout_result.dart';
import '../models/subscription_status_result.dart';

import '../services/subscription_service.dart';
import '../services/azampay_service.dart';

import '../utils/logger.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AzamPayService _azamPayService = AzamPayService(); // 🔑 AzamPay

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
          response?['message'] ?? 'Failed to load subscription packages',
        );
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
        paymentMethod: paymentMethod,
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

  /* ============================================================
   | START AZAMPAY CHECKOUT (AUTHORITATIVE)
   ============================================================ */
  Future<AzamCheckoutResult?> startCheckout({
    required int subscriptionId,
    required int amount,
    required String phone,
    required String provider, // 🔑 AIRTEL / VODACOM / TIGO / HALOTEL
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
   | CHECK SUBSCRIPTION STATUS (READ-ONLY)
   ============================================================ */
  Future<SubscriptionStatusResult?> checkSubscriptionStatus(
    int subscriptionId,
  ) async {
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

      final subscriptionJson = data['data']?['subscription'];
      if (subscriptionJson == null) {
        _errorMessage = 'Subscription data missing from response';
        notifyListeners();
        return null;
      }

      return SubscriptionStatusResult.fromJson(subscriptionJson);
    } catch (e) {
      _errorMessage = 'An error occurred while checking subscription status.';
      notifyListeners();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
// GET SUBSCRIPTION PACKAGES (REQUIRED BY subscription_screen.dart)
// ---------------------------------------------------------------------------
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
