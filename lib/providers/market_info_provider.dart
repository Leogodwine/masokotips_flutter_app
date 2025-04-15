import 'package:flutter/foundation.dart';
import 'package:masoko_tips/models/market_info.dart';
import 'package:masoko_tips/services/market_info_service.dart';

class MarketInfoProvider with ChangeNotifier {
  final MarketInfoService _marketInfoService = MarketInfoService();
  List<MarketInfo> _marketInfoList = [];
  bool _isLoading = false;
  String? _error;

  List<MarketInfo> get marketInfoList => _marketInfoList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMarketInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marketInfoList = await _marketInfoService.getAllMarketInfo();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMarketInfo({
    required String title,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
  }) async {
    try {
      final newMarketInfo = await _marketInfoService.addMarketInfo(
        title: title,
        description: content,
        contact: location ?? '',
      );
      _marketInfoList.add(newMarketInfo);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMarketInfo({
    required int id,
    required String title,
    required String content,
    String? imageUrl,
    String? location,
    String? category,
  }) async {
    try {
      final updatedMarketInfo = await _marketInfoService.updateMarketInfo(
        id: id.toString(),
        title: title,
        content: content,
        imageUrl: imageUrl,
        location: location,
        category: category,
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

  Future<void> deleteMarketInfo(int id) async {
    try {
      await _marketInfoService.deleteMarketInfo(id.toString());
      _marketInfoList.removeWhere((info) => info.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
