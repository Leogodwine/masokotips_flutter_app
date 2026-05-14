import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transport.dart';
import '../config/api_config.dart';
import '../utils/api_response.dart';
import '../utils/extensions.dart'; // Add extensions

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

  Future<List<Transport>> getTransports(
      {String? categoryId, String? vehicleType, String? status}) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (vehicleType != null) queryParams['vehicle_type'] = vehicleType;
      if (status != null) queryParams['status'] = status;

      // Build URI with query parameters
      final uri = Uri.parse('${ApiConfig.baseUrl}/public/transports').replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null);

      debugPrint('Fetching transports from API: $uri');
      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(_authToken),
      );

      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            ApiResponse.decodeJson(response.body);
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
      throw Exception('Error fetching transports: ${e.toFriendlyError}');
    }
  }

  Future<List<Transport>> getFeaturedTransports() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/transports/featured');
      debugPrint('Fetching featured transports from API: $uri');
      
      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(_authToken),
      );

      debugPrint('Featured transports API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            ApiResponse.decodeJson(response.body);
        if (responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          return data.map((transport) => Transport.fromJson(transport)).toList();
        } else {
          throw Exception('Response does not contain data field');
        }
      } else {
        throw Exception(
            'Failed to fetch featured transports. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getFeaturedTransports: $e');
      throw Exception('Error fetching featured transports: ${e.toFriendlyError}');
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
    double? latitude,
    double? longitude,
  }) async {
    _checkAuthToken();
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/transports'),
        headers: ApiConfig.getHeaders(_authToken),
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
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 201) {
        final data = ApiResponse.decodeJson(response.body)['data'];
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
        headers: ApiConfig.getHeaders(_authToken),
        body: jsonEncode(transport.toJson()),
      );

      if (response.statusCode == 200) {
        final data = ApiResponse.decodeJson(response.body)['data'];
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
        headers: ApiConfig.getHeaders(_authToken),
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
      final jsonData = ApiResponse.decodeJson(responseData);

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

