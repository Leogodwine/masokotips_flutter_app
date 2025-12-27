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
    return SubscriptionStatusResult(
      success: json['success'] == true,
      isActive: json['is_active'] == true,
      status: json['status'] ?? 'UNKNOWN',
      message: json['message'],
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
    );
  }
}
