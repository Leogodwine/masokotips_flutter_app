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
  String? _fromLocation;
  String? _toLocation;
  DateTime? _departureDate;

  List<Transport> get transports => _filteredTransports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter getters
  String? get selectedProductType => _selectedProductType;
  double? get minCapacity => _minCapacity;
  double? get maxPrice => _maxPrice;
  bool? get temperatureControlled => _temperatureControlled;
  String? get fromLocation => _fromLocation;
  String? get toLocation => _toLocation;
  DateTime? get departureDate => _departureDate;

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

      if (_fromLocation != null) {
        matches = matches &&
            transport.fromLocation
                .toLowerCase()
                .contains(_fromLocation!.toLowerCase());
      }

      if (_toLocation != null) {
        matches = matches &&
            transport.toLocation
                .toLowerCase()
                .contains(_toLocation!.toLowerCase());
      }

      if (_departureDate != null) {
        matches = matches &&
            transport.departureTime.year == _departureDate!.year &&
            transport.departureTime.month == _departureDate!.month &&
            transport.departureTime.day == _departureDate!.day;
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

  void setLocationFilters(String? fromLocation, String? toLocation) {
    _fromLocation = fromLocation;
    _toLocation = toLocation;
    _applyFilters();
  }

  void setDepartureDateFilter(DateTime? date) {
    _departureDate = date;
    _applyFilters();
  }

  void clearFilters() {
    _selectedProductType = null;
    _minCapacity = null;
    _maxPrice = null;
    _temperatureControlled = null;
    _fromLocation = null;
    _toLocation = null;
    _departureDate = null;
    _filteredTransports = _transports;
    notifyListeners();
  }

  Future<Transport> addTransport({
    required String title,
    required String description,
    required String fromLocation,
    required String toLocation,
    required String vehicleType,
    required DateTime departureTime,
    required DateTime arrivalTime,
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
        fromLocation: fromLocation,
        toLocation: toLocation,
        vehicleType: vehicleType,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
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
      String transportId, String imagePath) async {
    try {
      return await _transportService.uploadTransportImage(
          transportId, imagePath);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _transportService.deleteTransport(id);
      _transports.removeWhere((transport) => transport.id == id);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Transport> filterTransports({
    String? searchQuery,
    String? vehicleType,
    String? fromLocation,
    String? toLocation,
    DateTime? departureTime,
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

      if (fromLocation != null && transport.fromLocation != fromLocation) {
        return false;
      }

      if (toLocation != null && transport.toLocation != toLocation) {
        return false;
      }

      if (departureTime != null &&
          transport.departureTime.isBefore(departureTime)) {
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
