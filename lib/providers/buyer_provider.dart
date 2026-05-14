import 'dart:io';
import 'package:flutter/material.dart';
import '../models/buying_request.dart';
import '../services/buyer_service.dart';

class BuyerProvider with ChangeNotifier {
  final BuyerService _buyerService = BuyerService();
  
  List<BuyingRequest> _myRequests = [];
  bool _isLoading = false;
  String? _error;

  List<BuyingRequest> get myRequests => _myRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myRequests = await _buyerService.getMyRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRequest({
    required String title,
    required String description,
    required double quantity,
    required String unit,
    required String deliveryLocation,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRequest = await _buyerService.createRequest(
        title: title,
        description: description,
        quantity: quantity,
        unit: unit,
        deliveryLocation: deliveryLocation,
        imageFile: imageFile,
      );
      
      _myRequests.insert(0, newRequest);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRequest(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _buyerService.deleteRequest(id);
      _myRequests.removeWhere((request) => request.id == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
