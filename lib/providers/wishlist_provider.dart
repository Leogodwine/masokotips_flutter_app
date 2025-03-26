import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _wishlistItems = [];
  static const String _storageKey = 'wishlist_data';

  WishlistProvider() {
    _loadFromPrefs();
  }

  List<Product> get wishlistItems => List.unmodifiable(_wishlistItems);

  bool isInWishlist(int productId) {
    return _wishlistItems.any((item) => item.id == productId);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistData = prefs.getString(_storageKey);

    if (wishlistData != null) {
      final List<dynamic> decodedData = json.decode(wishlistData);
      _wishlistItems.clear();

      for (var item in decodedData) {
        _wishlistItems.add(Product.fromJson(item));
      }

      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data =
        _wishlistItems.map((product) => product.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(data));
  }

  void addToWishlist(Product product) {
    if (!isInWishlist(product.id)) {
      _wishlistItems.add(product);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeFromWishlist(int productId) {
    _wishlistItems.removeWhere((item) => item.id == productId);
    _saveToPrefs();
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistItems.clear();
    _saveToPrefs();
    notifyListeners();
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }
}
