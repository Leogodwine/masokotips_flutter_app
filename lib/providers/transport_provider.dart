import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TransportProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _transportServices = {
    'Tandem': {
      'imageUrl': 'https://example.com/tandem.jpg',
      'description':
          'Efficient tandem truck service for bulk transportation. Perfect for agricultural produce and construction materials.',
      'specifications': {
        'Capacity': '20-25 tons',
        'Length': '12.2 meters',
        'Loading Type': 'Side and rear loading',
        'Features': 'GPS tracking, Temperature monitoring'
      },
      'serviceAreas': ['Nairobi', 'Mombasa', 'Nakuru', 'Kisumu'],
      'baseRate': 100,
      'minDistance': 50,
      'additionalCharges': 'Loading/Unloading: \$50 per hour',
      'isAvailable': true,
      'providerName': 'Swift Transport Ltd',
      'providerDescription':
          'Professional transport service with 10+ years experience',
      'providerPhone': '+254700000000',
      'providerEmail': 'info@swifttransport.com',
      'providerImage': 'https://example.com/provider.jpg'
    },
    'Kirikuu': {
      'imageUrl': 'https://example.com/kirikuu.jpg',
      'description':
          'Versatile Kirikuu trucks suitable for medium-sized cargo transport. Ideal for urban and inter-city deliveries.',
      'specifications': {
        'Capacity': '10-15 tons',
        'Length': '8.5 meters',
        'Loading Type': 'Rear loading',
        'Features': 'Real-time tracking, 24/7 support'
      },
      'serviceAreas': ['Nairobi', 'Thika', 'Machakos', 'Kitui'],
      'baseRate': 80,
      'minDistance': 30,
      'additionalCharges': 'Waiting time: \$30 per hour',
      'isAvailable': true,
      'providerName': 'Express Logistics',
      'providerDescription': 'Reliable and efficient logistics solutions',
      'providerPhone': '+254711111111',
      'providerEmail': 'info@expresslogistics.com',
      'providerImage': 'https://example.com/provider2.jpg'
    },
    'FlatbedTrucks': {
      'imageUrl': 'https://example.com/flatbed.jpg',
      'description':
          'Spacious flatbed trucks for oversized and specialized cargo. Perfect for machinery and construction equipment.',
      'specifications': {
        'Capacity': '25-30 tons',
        'Length': '13.6 meters',
        'Loading Type': 'Side and top loading',
        'Features': 'Hydraulic ramps, Load securing equipment'
      },
      'serviceAreas': ['Nairobi', 'Mombasa', 'Eldoret', 'Nakuru'],
      'baseRate': 120,
      'minDistance': 100,
      'additionalCharges': 'Special equipment: \$100 per day',
      'isAvailable': true,
      'providerName': 'Heavy Haulers Co.',
      'providerDescription':
          'Specialized in heavy and oversized cargo transport',
      'providerPhone': '+254722222222',
      'providerEmail': 'info@heavyhaulers.com',
      'providerImage': 'https://example.com/provider3.jpg'
    }
  };

  Map<String, Map<String, dynamic>> get transportServices => _transportServices;

  Map<String, dynamic>? getTransportDetails(String type) {
    return _transportServices[type];
  }

  Future<void> updateAvailability(String type, bool isAvailable) async {
    if (_transportServices.containsKey(type)) {
      _transportServices[type]?['isAvailable'] = isAvailable;
      notifyListeners();
      await _saveToPrefs();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'transport_services', json.encode(_transportServices));
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transport_services');
    if (data != null) {
      final Map<String, dynamic> decoded = json.decode(data);
      _transportServices.clear();
      decoded.forEach((key, value) {
        _transportServices[key] = Map<String, dynamic>.from(value);
      });
      notifyListeners();
    }
  }
}
