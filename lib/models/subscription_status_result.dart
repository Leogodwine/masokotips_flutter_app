// models/subscription_status_result.dart

import 'subscription.dart';

class SubscriptionStatusResult {
  final bool success;
  final bool isActive;
  final String status;
  final String? message;
  final Subscription? subscription;

  SubscriptionStatusResult({
    required this.success,
    required this.isActive,
    required this.status,
    this.message,
    this.subscription,
  });

  factory SubscriptionStatusResult.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString() ?? 'UNKNOWN';
    final subscriptionStatus =
        json['subscription_status']?.toString() ?? rawStatus;
    final isActive = json['is_active'] == true || rawStatus == 'active';

    String resolvedStatus = rawStatus;
    if (isActive) {
      resolvedStatus = 'active';
    } else if (subscriptionStatus == 'failed' ||
        subscriptionStatus == 'cancelled') {
      resolvedStatus = subscriptionStatus;
    }

    return SubscriptionStatusResult(
      success: json['success'] == true,
      isActive: isActive,
      status: resolvedStatus,
      message: json['message'],
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
    );
  }
}
