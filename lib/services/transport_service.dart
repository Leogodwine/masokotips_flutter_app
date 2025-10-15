import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transport.dart';
import '../config/api_config.dart';

class TransportService {
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void _checkAuthToken() {
    if (_authToken == null) {
      throw Exception('Authentication token is not set');
    }
  }

  Future<List<Transport>> getTransports() async {
    try {
      debugPrint('Fetching transports from API...');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/public/transports'),
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          debugPrint('Parsed ${data.length} transports from response');
          return data.map((transport) {
            try {
              debugPrint('Transport data before parsing: $transport');
              debugPrint(
                  'Supported product types: ${transport['supported_product_types']}');
              return Transport.fromJson(transport);
            } catch (e) {
              debugPrint('Error parsing transport: $e');
              debugPrint('Transport data: $transport');
              rethrow;
            }
          }).toList();
        } else {
          throw Exception('Response does not contain data field');
        }
      } else {
        throw Exception(
            'Failed to fetch transports. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getTransports: $e');
      throw Exception('Error fetching transports: $e');
    }
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
    _checkAuthToken();
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/transports'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'vehicle_location': vehicleLocation,
          'vehicle_type': vehicleType,
          'price': price,
          'capacity': capacity,
          'is_temperature_controlled': isTemperatureControlled,
          'temperature_range': temperatureRange,
          'supported_product_types': supportedProductTypes,
          'driver_id': driverId,
          'driver_rating': driverRating,
          'has_insurance': hasInsurance,
          'insurance_details': insuranceDetails,
          'certifications': certifications,
          'amenities': amenities,
          'status': status,
          'image_url': imageUrl,
          'owner_name': ownerName,
          'price_per_kg': pricePerKg,
          'driver_name': driverName,
          'driver_phone': driverPhone,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        return Transport.fromJson(data);
      } else {
        throw Exception(
            'Failed to add transport. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding transport: $e');
    }
  }

  Future<Transport> updateTransport(Transport transport) async {
    _checkAuthToken();
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/transports/${transport.id}'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transport.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return Transport.fromJson(data);
      } else {
        throw Exception(
            'Failed to update transport. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating transport: $e');
    }
  }

  Future<void> deleteTransport(int id) async {
    _checkAuthToken();
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/transports/$id'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete transport. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting transport: $e');
    }
  }

  Future<String> uploadTransportImage(
      String transportId, String imageName, Uint8List imageBytes) async {
    _checkAuthToken();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/transports/$transportId/image'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_authToken',
        'Accept': 'application/json',
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonData['data']['image_url'];
      } else {
        throw Exception(
            'Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
