import 'package:flutter/foundation.dart';
import 'package:masoko_tips/models/market_info.dart';
import 'package:masoko_tips/services/market_info_service.dart';

class MarketInfoProvider extends ChangeNotifier {
  final MarketInfoService _marketInfoService;
  List<MarketInfo> _marketInfoList = [];
  bool _isLoading = false;
  String? _error;

  MarketInfoProvider({required MarketInfoService marketInfoService})
      : _marketInfoService = marketInfoService;

  // Expose the service for screens that need direct access
  MarketInfoService get marketInfoService => _marketInfoService;

  List<MarketInfo> get marketInfoList => _marketInfoList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMarketInfo() async {
    _setLoadingState(true);

    try {
      _marketInfoList = await _marketInfoService.getMarketInfo();
      _setErrorState(null);
    } catch (e) {
      _setErrorState(e.toString());
    } finally {
      _setLoadingState(false);
    }
  }

  Future<List<MarketInfo>> fetchMarketInfo() async {
    _setLoadingState(true);
    try {
      _marketInfoList = await _marketInfoService.getMarketInfo();
      _setErrorState(null);
      return _marketInfoList;
    } catch (e) {
      _setErrorState(e.toString());
      rethrow;
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> deleteMarketInfo(String id) async {
    await _marketInfoService.deleteMarketInfo(id);
    _marketInfoList.removeWhere((info) => info.id.toString() == id);
    _notifySafely();
  }

  Future<void> addMarketInfo({
    required String title,
    required String description,
    required String content,
    required String contact,
    String? location,
    String? category,
    String? imageUrl,
  }) async {
    _setLoadingState(true);
    try {
      final newInfo = await _marketInfoService.addMarketInfo(
        title: title,
        description: description,
        content: content,
        contact: contact,
        location: location,
        category: category,
        imageUrl: imageUrl,
      );
      _marketInfoList.add(newInfo);
      _setErrorState(null);
    } catch (e) {
      _setErrorState(e.toString());
      rethrow;
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> updateMarketInfo({
    required String id,
    required String title,
    required String description,
    required String content,
    String? location,
    String? category,
    String? imageUrl,
  }) async {
    final updatedInfo = await _marketInfoService.updateMarketInfo(
      id: id,
      title: title,
      description: description,
      content: content,
      location: location,
      category: category,
      imageUrl: imageUrl,
    );
    final index =
        _marketInfoList.indexWhere((info) => info.id.toString() == id);
    if (index != -1) {
      _marketInfoList[index] = updatedInfo;
      _notifySafely();
    }
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
