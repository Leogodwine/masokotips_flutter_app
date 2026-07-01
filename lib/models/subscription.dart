class SubscriptionPackage {
  final String id;
  final String name;
  final String description;
  final List<SubscriptionPlan> plans;
  final List<String> features;
  final String icon;
  final String color;
  final double? price;
  final String currency;

  SubscriptionPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.plans,
    required this.features,
    required this.icon,
    required this.color,
    this.price,
    required this.currency,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    // Extract price from package level or from first plan
    double? packagePrice;
    if (json['price'] != null) {
      packagePrice = json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.parse(json['price'].toString());
    } else {
      // Fallback to first plan's price
      final plans = json['plans'] as List;
      if (plans.isNotEmpty) {
        final firstPlan = plans.first;
        if (firstPlan['price'] != null) {
          packagePrice = firstPlan['price'] is num
              ? (firstPlan['price'] as num).toDouble()
              : double.parse(firstPlan['price'].toString());
        }
      }
    }

    return SubscriptionPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      plans: (json['plans'] as List)
          .map((plan) => SubscriptionPlan.fromJson(plan))
          .toList(),
      features: List<String>.from(json['features'] as List),
      icon: json['icon'] as String,
      color: json['color'] as String,
      price: packagePrice,
      currency: json['currency'] as String? ?? 'TZS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'plans': plans.map((plan) => plan.toJson()).toList(),
      'features': features,
      'icon': icon,
      'color': color,
      'price': price,
      'currency': currency,
    };
  }
}

class SubscriptionPlan {
  final String duration;
  final String durationLabel;
  final double? price;
  final double? originalPrice;
  final int? savings;
  final bool popular;
  final String? badge;

  SubscriptionPlan({
    required this.duration,
    required this.durationLabel,
    this.price,
    this.originalPrice,
    this.savings,
    required this.popular,
    this.badge,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      duration: json['duration'] as String,
      durationLabel: json['duration_label'] as String,
      price: json['price'] != null
          ? (json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.parse(json['price'].toString()))
          : null,
      originalPrice: json['original_price'] != null
          ? (json['original_price'] is num
              ? (json['original_price'] as num).toDouble()
              : double.parse(json['original_price'].toString()))
          : null,
      savings: json['savings'] as int?,
      popular: json['popular'] as bool? ?? false,
      badge: json['badge'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'duration_label': durationLabel,
      'price': price,
      'original_price': originalPrice,
      'savings': savings,
      'popular': popular,
      'badge': badge,
    };
  }
}

class Subscription {
  final int id;
  final int userId;
  final String subscriptionType;
  final double? amount;
  final String currency;
  final String status;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime? paymentDate;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.subscriptionType,
    this.amount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    this.expiresAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    // Handle both int and string IDs from API
    final id = json['id'] is String ? int.parse(json['id']) : json['id'] as int;
    final userId = json['user_id'] is String
        ? int.parse(json['user_id'])
        : json['user_id'] as int;

    return Subscription(
      id: id,
      userId: userId,
      subscriptionType: json['subscription_type'] as String,
      amount: json['amount'] != null
          ? (json['amount'] is num
              ? (json['amount'] as num).toDouble()
              : double.parse(json['amount'].toString()))
          : null,
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
      paymentReference: json['payment_reference'] as String?,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_type': subscriptionType,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
      'payment_date': paymentDate?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive {
    if (status != 'completed') return false;
    if (expiresAt == null) return true;
    return expiresAt!.isAfter(DateTime.now());
  }

  bool get isPending => status == 'pending' || status == 'pending_checkout';
  bool get isPendingCheckout => status == 'pending_checkout';
  bool get isFailed => status == 'failed';
  bool get isExpired => status == 'expired' || (status == 'completed' && expiresAt != null && expiresAt!.isBefore(DateTime.now()));
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    if (isExpired) return 'Expired';
    
    switch (status) {
      case 'pending':
        return 'Pending Payment';
      case 'pending_checkout':
        return 'Payment Processing';
      case 'completed':
        return 'Active';
      case 'failed':
        return 'Failed';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get typeLabel {
    switch (subscriptionType) {
      case 'buyer':
        return 'Buyer Membership';
      case 'seller':
        return 'Seller Membership';
      case 'service_provider':
        return 'Service Provider Membership';
      case 'transporter':
        return 'Transporter Membership';
      default:
        return subscriptionType;
    }
  }
}

class SubscriptionResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  SubscriptionResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'],
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };
  }
}

class PaymentVerificationRequest {
  final String paymentReference;
  final String transactionId;

  PaymentVerificationRequest({
    required this.paymentReference,
    required this.transactionId,
  });

  factory PaymentVerificationRequest.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationRequest(
      paymentReference: json['payment_reference'] as String,
      transactionId: json['transaction_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_reference': paymentReference,
      'transaction_id': transactionId,
    };
  }
}

class CreateSubscriptionRequest {
  final String subscriptionType;
  final String duration;
  final String paymentMethod;
  final String? phone;
  final String? accountNumber;

  CreateSubscriptionRequest({
    required this.subscriptionType,
    required this.duration,
    required this.paymentMethod,
    this.phone,
    this.accountNumber,
  });

  factory CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionRequest(
      subscriptionType: json['subscription_type'] as String,
      duration: json['duration'] as String,
      paymentMethod: json['payment_method'] as String,
      phone: json['phone'] as String?,
      accountNumber: json['account_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_type': subscriptionType,
      'duration': duration,
      'payment_method': paymentMethod,
      'phone': phone,
      'account_number': accountNumber,
    };
  }
}
