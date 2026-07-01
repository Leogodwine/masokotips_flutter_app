class AgentStats {
  final int totalReferred;
  final int converted;
  final double pendingEarnings;
  final double totalEarned;
  final double paidOut;
  final double commissionRate;

  const AgentStats({
    required this.totalReferred,
    required this.converted,
    required this.pendingEarnings,
    required this.totalEarned,
    required this.paidOut,
    required this.commissionRate,
  });

  factory AgentStats.fromJson(Map<String, dynamic> json) {
    return AgentStats(
      totalReferred:    (json['total_referred']   as num? ?? 0).toInt(),
      converted:        (json['converted']         as num? ?? 0).toInt(),
      pendingEarnings:  (json['pending_earnings']  as num? ?? 0).toDouble(),
      totalEarned:      (json['total_earned']      as num? ?? 0).toDouble(),
      paidOut:          (json['paid_out']          as num? ?? 0).toDouble(),
      commissionRate:   (json['commission_rate']   as num? ?? 100).toDouble(),
    );
  }
}

class AgentReferral {
  final int id;
  final String name;
  final String? phone;
  final String role;
  final String? referredAt;
  final bool hasSubscription;
  final String? subscriptionType;

  const AgentReferral({
    required this.id,
    required this.name,
    this.phone,
    required this.role,
    this.referredAt,
    required this.hasSubscription,
    this.subscriptionType,
  });

  factory AgentReferral.fromJson(Map<String, dynamic> json) {
    return AgentReferral(
      id:               (json['id'] as num).toInt(),
      name:             json['name'] as String? ?? '—',
      phone:            json['phone'] as String?,
      role:             json['role'] as String? ?? '—',
      referredAt:       json['referred_at'] as String?,
      hasSubscription:  json['has_subscription'] == true,
      subscriptionType: json['subscription_type'] as String?,
    );
  }
}

class AgentEarning {
  final int id;
  final String referredUser;
  final String? subscriptionType;
  final double commission;
  final String currency;
  final String status;
  final String earnedAt;
  final String? paidAt;

  bool get isPaid => status == 'paid';

  const AgentEarning({
    required this.id,
    required this.referredUser,
    this.subscriptionType,
    required this.commission,
    required this.currency,
    required this.status,
    required this.earnedAt,
    this.paidAt,
  });

  factory AgentEarning.fromJson(Map<String, dynamic> json) {
    return AgentEarning(
      id:               (json['id'] as num).toInt(),
      referredUser:     json['referred_user'] as String? ?? '—',
      subscriptionType: json['subscription_type'] as String?,
      commission:       (json['commission'] as num? ?? 0).toDouble(),
      currency:         json['currency'] as String? ?? 'TZS',
      status:           json['status'] as String? ?? 'pending',
      earnedAt:         json['earned_at'] as String? ?? '',
      paidAt:           json['paid_at'] as String?,
    );
  }
}
