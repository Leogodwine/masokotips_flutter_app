class AzamCheckoutResult {
  final bool success;
  final String checkoutUrl;
  final String transactionId;
  final String message;

  AzamCheckoutResult({
    required this.success,
    required this.checkoutUrl,
    required this.transactionId,
    required this.message,
  });

  factory AzamCheckoutResult.fromJson(Map<String, dynamic> json) {
    return AzamCheckoutResult(
      success: json['success'] == true,
      checkoutUrl: json['checkout_url'] ?? json['payment_url'] ?? '',
      transactionId: json['transaction_id'] ?? json['external_id'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
