import 'package:flutter/foundation.dart';
import '../models/organic_product.dart';
import '../services/organic_product_service.dart';

class OrganicProductProvider with ChangeNotifier {
  final OrganicProductService _service;
  List<OrganicProduct> _products = [];
  bool _isLoading = false;
  String? _error;

  OrganicProductProvider(this._service);

  OrganicProductService get service => _service;
  List<OrganicProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.getOrganicProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(OrganicProduct product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProduct = await _service.createOrganicProduct(product);
      _products.add(newProduct);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(OrganicProduct product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProduct = await _service.updateOrganicProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteOrganicProduct(id);
      _products.removeWhere((product) => product.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrganicProduct?> getProduct(int id) async {
    try {
      return await _service.getOrganicProduct(id);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }
}
