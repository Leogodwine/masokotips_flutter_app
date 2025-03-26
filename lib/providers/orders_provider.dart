import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];
  static const String _storageKey = 'orders';

  List<Order> get orders => _orders;

  OrdersProvider() {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_storageKey);
    if (ordersJson != null) {
      final List<dynamic> decoded = json.decode(ordersJson);
      _orders = decoded.map((json) => Order.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson =
        json.encode(_orders.map((order) => order.toJson()).toList());
    await prefs.setString(_storageKey, ordersJson);
  }

  void addOrder({
    required List<CartItem> cartItems,
    required double total,
    required String address,
    required String phone,
    required String paymentMethod,
  }) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: cartItems,
      totalAmount: total,
      deliveryAddress: address,
      phoneNumber: phone,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    _saveOrders();
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex].status = status;
      _saveOrders();
      notifyListeners();
    }
  }
}
