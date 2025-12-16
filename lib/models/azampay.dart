class AzamPayCheckoutStatusResult {
  final bool success;
  final String status;
  final bool isPaid;
  final String? message;

  AzamPayCheckoutStatusResult({
    required this.success,
    required this.status,
    required this.isPaid,
    this.message,
  });

  factory AzamPayCheckoutStatusResult.fromJson(Map<String, dynamic> json) {
    return AzamPayCheckoutStatusResult(
      success: json['success'] == true,
      status: json['status'] ?? 'UNKNOWN',
      isPaid: json['is_paid'] == true,
      message: json['message'],
    );
  }
}
