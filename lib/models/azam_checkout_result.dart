// lib/models/azam_checkout_result.dart

class AzamCheckoutResult {
  final bool success;
  final String? externalId; // 🔑 REQUIRED FOR POLLING
  final String? message;

  AzamCheckoutResult({
    required this.success,
    this.externalId,
    this.message,
  });

  factory AzamCheckoutResult.fromJson(Map<String, dynamic> json) {
    return AzamCheckoutResult(
      success: json['success'] == true,
      externalId: json['externalId'],
      message: json['message'],
    );
  }
}
