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
    _setLoadingState(true);

    try {
      _marketInfoList = await _marketInfoService.getAllMarketInfo();
      _setErrorState(null);
    } catch (e) {
      _setErrorState(e.toString());
    } finally {
      _setLoadingState(false);
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
      _notifySafely();
    } catch (e) {
      _setErrorState(e.toString());
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
        _notifySafely();
      }
    } catch (e) {
      _setErrorState(e.toString());
      rethrow;
    }
  }

  Future<void> deleteMarketInfo(String id) async {
    try {
      await _marketInfoService.deleteMarketInfo(id);
      await loadMarketInfo();
    } catch (e) {
      _setErrorState(e.toString());
    }
  }

  void setAuthToken(String token) {
    _marketInfoService.setAuthToken(token);
  }

  // Helper to set loading state
  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    _notifySafely();
  }

  // Helper to set error state
  void _setErrorState(String? error) {
    _error = error;
    _notifySafely();
  }

  // Safely call notifyListeners
  void _notifySafely() {
    if (!kDebugMode) {
      notifyListeners();
    } else {
      Future.microtask(() => notifyListeners());
    }
  }
}
