import 'package:flutter/foundation.dart';
import 'package:masoko_tips/models/market_info.dart';
import 'package:masoko_tips/services/market_info_service.dart';

class MarketInfoProvider extends ChangeNotifier {
  final MarketInfoService _marketInfoService;
  List<MarketInfo> _marketInfoList = [];
  bool _isLoading = false;
  String? _error;

  MarketInfoProvider({MarketInfoService? marketInfoService})
      : _marketInfoService = marketInfoService ?? MarketInfoService();

  List<MarketInfo> get marketInfoList => _marketInfoList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMarketInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marketInfoList = await _marketInfoService.getAllMarketInfo();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMarketInfo({
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
    String? contact,
  }) async {
    try {
      final marketInfo = await _marketInfoService.addMarketInfo(
        title: title,
        description: description,
        content: content,
        imageUrl: imageUrl,
        location: location,
        category: category,
        contact: contact,
      );
      _marketInfoList.add(marketInfo);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMarketInfo({
    required String id,
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
    String? contact,
  }) async {
    try {
      final updatedMarketInfo = await _marketInfoService.updateMarketInfo(
        id: id,
        title: title,
        description: description,
        content: content,
        imageUrl: imageUrl,
        location: location,
        category: category,
        contact: contact,
      );
      final index = _marketInfoList.indexWhere((info) => info.id == id);
      if (index != -1) {
        _marketInfoList[index] = updatedMarketInfo;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMarketInfo(String id) async {
    try {
      await _marketInfoService.deleteMarketInfo(id);
      await loadMarketInfo();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setAuthToken(String token) {
    _marketInfoService.setAuthToken(token);
  }
}
