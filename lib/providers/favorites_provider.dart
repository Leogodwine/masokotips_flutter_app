import 'package:flutter/foundation.dart';
import '../models/service.dart';

class FavoritesProvider with ChangeNotifier {
  final Map<String, Service> _items = {};

  Map<String, Service> get items => {..._items};

  int get itemCount => _items.length;

  bool isFavorite(String serviceId) => _items.containsKey(serviceId);

  void toggleFavorite(Service service) {
    if (_items.containsKey(service.id)) {
      _items.remove(service.id);
    } else {
      _items[service.id] = service;
    }
    notifyListeners();
  }

  void removeFromFavorites(String serviceId) {
    _items.remove(serviceId);
    notifyListeners();
  }
}
