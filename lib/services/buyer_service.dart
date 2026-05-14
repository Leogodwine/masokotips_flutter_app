import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/buying_request.dart';

class BuyerService {
  Future<Map<String, String>> _getHeaders([bool isMultipart = false]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      if (!isMultipart) 'Content-Type': 'application/json',
    };
  }

  Future<List<BuyingRequest>> getMyRequests() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/buyer/requests'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => BuyingRequest.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<BuyingRequest> createRequest({
    required String title,
    required String description,
    required double quantity,
    required String unit,
    required String deliveryLocation,
    File? imageFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/buyer/requests'),
      );

      request.headers.addAll(await _getHeaders(true));

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['quantity'] = quantity.toString();
      request.fields['unit'] = unit;
      request.fields['delivery_location'] = deliveryLocation;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return BuyingRequest.fromJson(data['data']);
      } else if (response.statusCode == 403) {
        throw Exception('Subscription required to post buying requests');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create request');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteRequest(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/buyer/requests/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete request');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
