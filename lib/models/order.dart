import 'cart_item.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final String phoneNumber;
  final String paymentMethod;
  final DateTime createdAt;
  OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
        'phoneNumber': phoneNumber,
        'paymentMethod': paymentMethod,
        'createdAt': createdAt.toIso8601String(),
        'status': status.toString().split('.').last,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        items: (json['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList(),
        totalAmount: json['totalAmount'].toDouble(),
        deliveryAddress: json['deliveryAddress'],
        phoneNumber: json['phoneNumber'],
        paymentMethod: json['paymentMethod'],
        createdAt: DateTime.parse(json['createdAt']),
        status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        ),
      );
}
