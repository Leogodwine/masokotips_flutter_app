import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';
import '../utils/logger.dart';

/// Network service for handling API requests with proper error handling
/// and tool registration for the API integration
class NetworkService {
  static NetworkService? _instance;
  static NetworkService get instance => _instance ??= NetworkService._();

  NetworkService._();

  late final Dio _dio;
  String? _authToken;

  /// Initialize the network service with base configuration
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    // Add interceptors for logging and auth
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Log.d('🚀 API Request: ${options.method} ${options.uri}');
        Log.d('📤 Request Data: ${options.data}');

        // Add auth token if available
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }

        // Add enhanced headers to bypass bot detection
        options.headers.addAll(_getEnhancedHeaders());

        handler.next(options);
      },
      onResponse: (response, handler) {
        Log.d(
            '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
        Log.d('📥 Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        Log.e('❌ API Error: ${error.type} ${error.message}');
        Log.e('📥 Error Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  /// Enhanced headers to bypass bot detection
  Map<String, String> _getEnhancedHeaders() {
    return {
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9',
      'User-Agent': _getUserAgent(),
      'Origin': ApiConfig.baseUrl.replaceAll('/api', ''),
      'Referer': ApiConfig.baseUrl.replaceAll('/api', ''),
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
    };
  }

  /// User-Agent header to identify as legitimate mobile app
  String _getUserAgent() {
    if (Platform.isAndroid) {
      return 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1';
    } else {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Safari/537.36';
    }
  }

  /// Set authentication token for all subsequent requests
  void setAuthToken(String token) {
    _authToken = token;
    Log.d('🔐 Auth token set: ${token.substring(0, 10)}...');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    Log.d('🔓 Auth token cleared');
  }

  /// Check if currently authenticated
  bool get isAuthenticated => _authToken != null;

  /// Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload file with multipart request (supports both web and mobile)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String fileField,
    File file, {
    Map<String, String>? additionalFields,
    String? fileName,
  }) async {
    try {
      Log.d('🌐 Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');

      MultipartFile multipartFile;

      if (kIsWeb) {
        // Web platform - use bytes
        final bytes = await file.readAsBytes();
        final name = fileName ?? file.path.split('/').last;
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: name,
        );
        Log.d('📤 Web upload - file: $name, size: ${bytes.length} bytes');
      } else {
        // Mobile/desktop platform - use file path
        final name = fileName ?? file.path.split('/').last;
        multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: name,
        );
        Log.d('📱 Mobile upload - file: $name, path: ${file.path}');
      }

      final formData = FormData.fromMap({
        fileField: multipartFile,
        ...?additionalFields,
      });

      final response = await _dio.post(endpoint, data: formData);
      return _handleResponse(response);
    } on DioException catch (e) {
      Log.e('❌ Upload failed: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      Log.e('❌ General upload error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Upload file from bytes (useful for web uploads)
  Future<Map<String, dynamic>> uploadFileFromBytes(
    String endpoint,
    String fileField,
    List<int> bytes, {
    required String fileName,
    Map<String, String>? additionalFields,
  }) async {
    try {
      Log.d(
          '📤 Uploading file from bytes: $fileName, size: ${bytes.length} bytes');

      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
      );

      final formData = FormData.fromMap({
        fileField: multipartFile,
        ...?additionalFields,
      });

      final response = await _dio.post(endpoint, data: formData);
      return _handleResponse(response);
    } on DioException catch (e) {
      Log.e('❌ Upload from bytes failed: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      Log.e('❌ General upload error: $e');
      throw Exception('Upload from bytes failed: $e');
    }
  }

  /// Handle successful API response
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {'data': response.data};
      }
    } else {
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.statusMessage}',
      );
    }
  }

  /// Handle Dio errors and convert to meaningful exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
            'Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ??
            error.response?.data?['error'] ??
            'Server error';
        return Exception('Server error ($statusCode): $message');

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');

      default:
        return Exception('Network error: ${error.message}');
    }
  }

  /// Test API connectivity
  Future<bool> testConnection() async {
    try {
      await _dio.get('/health');
      return true;
    } catch (e) {
      Log.e('Connection test failed: $e');
      return false;
    }
  }

  /// Placeholder method for API tools/functions registration
  /// Note: Tool registration not needed for this implementation
  void registerApiTools() {
    // Tool registration is not required for this API implementation
    Log.d('🔧 Tool registration skipped (not needed for this API)');
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
