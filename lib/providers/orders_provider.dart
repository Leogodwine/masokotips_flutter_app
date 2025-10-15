import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];
  static const String _storageKey = 'orders';
  ApiService? _apiService;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrdersProvider() {
    _loadOrders();
  }

  void setApiService(ApiService apiService) {
    _apiService = apiService;
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_storageKey);
    if (ordersJson != null) {
      final List<dynamic> decoded = json.decode(ordersJson);
      _orders = decoded.map((json) => Order.fromApiJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson =
        json.encode(_orders.map((order) => order.toJson()).toList());
    await prefs.setString(_storageKey, ordersJson);
  }

  Future<void> addOrder({
    required List<CartItem> cartItems,
    required double total,
    required String address,
    required String phone,
    required String paymentMethod,
    String? notes,
  }) async {
    if (_apiService == null) {
      Log.e('ApiService not set in OrdersProvider');
      throw Exception('API service not available');
    }

    Log.e('OrdersProvider: ApiService is available');
    Log.e(
        'OrdersProvider: About to create order with ${cartItems.length} items');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Convert cart items to API format
      final List<Map<String, dynamic>> apiItems = cartItems
          .map((item) => {
                'product_id': item.id,
                'quantity': item.quantity,
              })
          .toList();

      Log.e('Creating order with ${cartItems.length} items');
      Log.e('Total: $total');
      Log.e('Address: $address');
      Log.e('Payment Method: $paymentMethod');

      // Create order via API
      final response = await _apiService!.createOrder(
        items: apiItems,
        shippingAddress: address,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      Log.e('Order created successfully via API');
      Log.e('API Response: $response');

      // Also save locally for offline access
      final order = Order(
        id: response['data']['id'].toString(),
        items: cartItems,
        totalAmount: total,
        deliveryAddress: address,
        phoneNumber: phone,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        status: OrderStatus.pending,
      );

      _orders.insert(0, order);
      await _saveOrders();

      Log.e('Order saved locally and via API');
    } catch (e) {
      Log.e('Error creating order: $e');
      Log.e('Error type: ${e.runtimeType}');
      Log.e('Error details: ${e.toString()}');
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    if (_apiService == null) {
      Log.e('ApiService not set in OrdersProvider');
      _error = 'API service not available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Log.e('Fetching orders from API...');
      final response = await _apiService!.getOrders();

      Log.e('Orders fetched successfully: $response');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> ordersData = response['data'];
        Log.e(
            'OrdersProvider: Found ${ordersData.length} orders in API response');

        if (ordersData.isNotEmpty) {
          Log.e('OrdersProvider: First order data: ${ordersData.first}');
        }

        try {
          _orders = ordersData.map((json) {
            Log.e('OrdersProvider: Parsing order: ${json['id']}');
            try {
              return Order.fromApiJson(json);
            } catch (e) {
              Log.e('Error parsing individual order ${json['id']}: $e');
              Log.e('Order JSON: $json');
              rethrow;
            }
          }).toList();
        } catch (e) {
          Log.e('Error in orders mapping: $e');
          rethrow;
        }
        await _saveOrders();
        Log.e('Orders loaded: ${_orders.length}');
      } else {
        _error = 'Failed to fetch orders';
        Log.e('Failed to fetch orders: $response');
      }
    } catch (e, stackTrace) {
      Log.e('Error fetching orders: $e');
      Log.e('Stack trace: $stackTrace');
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(String orderId) async {
    if (_apiService == null) {
      Log.e('ApiService not set in OrdersProvider');
      _error = 'API service not available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Log.e('Cancelling order: $orderId');
      final response = await _apiService!.cancelOrder(int.parse(orderId));

      Log.e('Order cancellation response: $response');

      if (response['success'] == true) {
        // Update the order status locally
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex].status = OrderStatus.cancelled;
          await _saveOrders();
          Log.e('Order cancelled successfully');
        }
      } else {
        _error = response['message'] ?? 'Failed to cancel order';
        Log.e('Failed to cancel order: $response');
      }
    } catch (e) {
      Log.e('Error cancelling order: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
