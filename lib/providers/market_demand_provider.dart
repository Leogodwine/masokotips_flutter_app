import 'package:flutter/material.dart';
import '../models/buying_request.dart';
import '../services/market_demand_service.dart';

class MarketDemandProvider with ChangeNotifier {
  final MarketDemandService _service = MarketDemandService();
  
  List<BuyingRequest> _demands = [];
  bool _isLoading = false;
  String? _error;

  List<BuyingRequest> get demands => _demands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDemands({String? search, bool refresh = false}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    if (refresh) _error = null;
    notifyListeners();

    try {
      _demands = await _service.getMarketDemands(search: search);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
