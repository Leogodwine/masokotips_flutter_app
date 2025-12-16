// models/checkout_status_result.dart

class AzamPayCheckoutStatusResult {
  final bool success;
  final bool isPaid;
  final String status;
  final String? message;

  AzamPayCheckoutStatusResult({
    required this.success,
    required this.isPaid,
    required this.status,
    this.message,
  });

  factory AzamPayCheckoutStatusResult.fromJson(Map<String, dynamic> json) {
    return AzamPayCheckoutStatusResult(
      success: json['success'] == true,
      isPaid: json['is_paid'] == true,
      status: json['status'] ?? 'UNKNOWN',
      message: json['message'],
    );
  }
}
