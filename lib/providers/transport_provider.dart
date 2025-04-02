import 'package:flutter/foundation.dart';
import '../models/transport.dart';
import '../services/transport_service.dart';

class TransportProvider with ChangeNotifier {
  final TransportService _transportService = TransportService();
  List<Transport> _transports = [];
  List<Transport> _filteredTransports = [];
  bool _isLoading = false;
  String? _error;

  // Filter states
  String? _selectedProductType;
  double? _minCapacity;
  double? _maxPrice;
  bool? _temperatureControlled;
  String? _vehicleLocation;

  List<Transport> get transports => _filteredTransports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  String? get selectedProductType => _selectedProductType;
  double? get minCapacity => _minCapacity;
  double? get maxPrice => _maxPrice;
  bool? get temperatureControlled => _temperatureControlled;
  String? get vehicleLocation => _vehicleLocation;

  TransportProvider();

  void initialize(String authToken) {
    _transportService.setAuthToken(authToken);
  }

  @override
  void dispose() {
    _transports.clear();
    _filteredTransports.clear();
    super.dispose();
  }

  Future<void> loadTransports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transports = await _transportService.getTransports();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredTransports = _transports.where((transport) {
      bool matches = true;

      if (_selectedProductType != null) {
        matches = matches &&
            transport.supportedProductTypes.contains(_selectedProductType);
      }

      if (_minCapacity != null) {
        matches = matches && transport.capacity >= _minCapacity!;
      }

      if (_maxPrice != null) {
        matches = matches && transport.price <= _maxPrice!;
      }

      if (_temperatureControlled != null) {
        matches = matches &&
            transport.isTemperatureControlled == _temperatureControlled;
      }

      if (_vehicleLocation != null && _vehicleLocation!.isNotEmpty) {
        matches = matches &&
            transport.vehicleLocation
                .toLowerCase()
                .contains(_vehicleLocation!.toLowerCase());
      }

      return matches;
    }).toList();
    notifyListeners();
  }

  // Filter setters
  void setProductTypeFilter(String? productType) {
    _selectedProductType = productType;
    _applyFilters();
  }

  void setCapacityFilter(double? minCapacity) {
    _minCapacity = minCapacity;
    _applyFilters();
  }

  void setPriceFilter(double? maxPrice) {
    _maxPrice = maxPrice;
    _applyFilters();
  }

  void setTemperatureControlledFilter(bool? temperatureControlled) {
    _temperatureControlled = temperatureControlled;
    _applyFilters();
  }

  void setVehicleLocationFilter(String? location) {
    _vehicleLocation = location;
    _applyFilters();
  }

  void clearFilters() {
    _selectedProductType = null;
    _minCapacity = null;
    _maxPrice = null;
    _temperatureControlled = null;
    _vehicleLocation = null;
    _filteredTransports = _transports;
    notifyListeners();
  }

  Future<Transport> addTransport({
    required String title,
    required String description,
    required String vehicleLocation,
    required String vehicleType,
    required double price,
    required double capacity,
    required bool isTemperatureControlled,
    double? temperatureRange,
    required List<String> supportedProductTypes,
    String? driverId,
    double? driverRating,
    required bool hasInsurance,
    String? insuranceDetails,
    Map<String, dynamic>? certifications,
    List<String>? amenities,
    String status = 'active',
    String? imageUrl,
    required String ownerName,
    double? pricePerKg,
    required String driverName,
    required String driverPhone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final transport = await _transportService.addTransport(
        title: title,
        description: description,
        vehicleLocation: vehicleLocation,
        vehicleType: vehicleType,
        price: price,
        capacity: capacity,
        isTemperatureControlled: isTemperatureControlled,
        temperatureRange: temperatureRange,
        supportedProductTypes: supportedProductTypes,
        driverId: driverId,
        driverRating: driverRating,
        hasInsurance: hasInsurance,
        insuranceDetails: insuranceDetails,
        certifications: certifications,
        amenities: amenities,
        status: status,
        imageUrl: imageUrl,
        ownerName: ownerName,
        pricePerKg: pricePerKg,
        driverName: driverName,
        driverPhone: driverPhone,
      );

      _transports.add(transport);
      _applyFilters();
      _error = null;
      notifyListeners();
      return transport;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadTransportImage(
      String transportId, String imageName, Uint8List imageBytes) async {
    try {
      return await _transportService.uploadTransportImage(
          transportId, imageName, imageBytes);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTransport(Transport transport) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedTransport =
          await _transportService.updateTransport(transport);
      final index = _transports.indexWhere((t) => t.id == transport.id);
      if (index != -1) {
        _transports[index] = updatedTransport;
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransport(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _transportService.deleteTransport(id);

      // Remove from both lists
      _transports.removeWhere((transport) => transport.id == id);
      _filteredTransports.removeWhere((transport) => transport.id == id);

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Transport> filterTransports({
    String? searchQuery,
    String? vehicleType,
    String? vehicleLocation,
    double? minPrice,
    double? maxPrice,
    bool? isTemperatureControlled,
    List<String>? productTypes,
  }) {
    return _transports.where((transport) {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (!transport.title
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) &&
            !transport.description
                .toLowerCase()
                .contains(searchQuery.toLowerCase())) {
          return false;
        }
      }

      if (vehicleType != null && transport.vehicleType != vehicleType) {
        return false;
      }

      if (vehicleLocation != null &&
          !transport.vehicleLocation
              .toLowerCase()
              .contains(vehicleLocation.toLowerCase())) {
        return false;
      }

      if (minPrice != null && transport.price < minPrice) {
        return false;
      }

      if (maxPrice != null && transport.price > maxPrice) {
        return false;
      }

      if (isTemperatureControlled != null &&
          transport.isTemperatureControlled != isTemperatureControlled) {
        return false;
      }

      if (productTypes != null && productTypes.isNotEmpty) {
        if (!productTypes
            .any((type) => transport.supportedProductTypes.contains(type))) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
