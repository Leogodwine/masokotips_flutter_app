import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};
  static const String _storageKey = 'cart_data';

  CartProvider() {
    _loadFromPrefs();
  }

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.total);
  }

  double get tax => subtotal * 0.1; // 10% tax

  double get total => subtotal + tax;

  double get shippingCost => 5.0;

  bool isInCart(int productId) => _items.containsKey(productId);

  int getQuantity(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString(_storageKey);

    if (cartData != null) {
      final Map<String, dynamic> decodedData = json.decode(cartData);
      final Map<String, dynamic> items = decodedData['items'];

      items.forEach((key, value) {
        final int productId = int.parse(key);
        _items[productId] = CartItem(
          product: Product.fromJson(value['product']),
          quantity: value['quantity'],
        );
      });

      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> cartItems = {};
    _items.forEach((key, value) {
      cartItems[key.toString()] = {
        'product': value.product.toJson(),
        'quantity': value.quantity,
      };
    });

    final Map<String, dynamic> data = {
      'items': cartItems,
    };

    await prefs.setString(_storageKey, json.encode(data));
  }

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.remove(productId);
    _saveToPrefs();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: quantity,
        ),
      );
      _saveToPrefs();
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }

  bool get isEmpty => _items.isEmpty;
}
