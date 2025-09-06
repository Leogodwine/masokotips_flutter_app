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
        totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0.0,
        deliveryAddress: json['deliveryAddress'],
        phoneNumber: json['phoneNumber'],
        paymentMethod: json['paymentMethod'],
        createdAt: DateTime.parse(json['createdAt']),
        status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        ),
      );

  factory Order.fromApiJson(Map<String, dynamic> json) {
    try {
      print('Order.fromApiJson: Parsing order with ID: ${json['id']}');

      // Convert API order items to CartItem format
      List<CartItem> items = [];
      if (json['items'] != null) {
        print(
            'Order.fromApiJson: Found ${(json['items'] as List).length} items');
        items = (json['items'] as List).map((item) {
          print(
              'Order.fromApiJson: Parsing item with product_id: ${item['product_id']}');
          print(
              'Order.fromApiJson: Item price: ${item['price']} (type: ${item['price'].runtimeType})');

          return CartItem(
            id: int.tryParse(item['product_id']?.toString() ?? '0') ?? 0,
            name: item['product_details']?['name'] ??
                item['product']?['name'] ??
                'Unknown Product',
            price: double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
            quantity: item['quantity'] ?? 1,
            imageUrl: item['product_details']?['image'] ??
                item['product']?['image'] ??
                '',
          );
        }).toList();
      }

      return Order(
        id: json['id'].toString(),
        items: items,
        totalAmount: double.tryParse(
                (json['total_amount'] ?? json['totalAmount'] ?? 0)
                    .toString()) ??
            0.0,
        deliveryAddress:
            json['shipping_address'] ?? json['deliveryAddress'] ?? '',
        phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
        paymentMethod:
            json['payment_method'] ?? json['paymentMethod'] ?? 'Unknown',
        createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
        status: _parseOrderStatus(json['status']),
      );
    } catch (e, stackTrace) {
      print('Error in Order.fromApiJson: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  static OrderStatus _parseOrderStatus(String? status) {
    if (status == null) {
      return OrderStatus.pending;
    }

    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
