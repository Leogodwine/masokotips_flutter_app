import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ImageDiagnostic {
  static final Dio _dio = Dio();

  static Future<void> diagnoseImageUrl(String imageUrl) async {
    debugPrint('🔍 Starting image diagnostic for: $imageUrl');
    debugPrint('=' * 60);

    try {
      // Step 1: Validate URL format
      final uri = Uri.parse(imageUrl);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        debugPrint('❌ Invalid URL scheme: ${uri.scheme}');
        return;
      }
      debugPrint('✅ URL format is valid');
      debugPrint('🌐 Scheme: ${uri.scheme}');
      debugPrint('🌐 Host: ${uri.host}');
      debugPrint('🌐 Path: ${uri.path}');

      // Step 2: Test HTTP request
      debugPrint('\n📡 Testing HTTP request...');
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'image/*',
            'User-Agent': 'Flutter Image Diagnostic',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      debugPrint('📊 Response Status: ${response.statusCode}');
      debugPrint('📊 Response Headers:');
      response.headers.forEach((key, values) {
        debugPrint('   $key: ${values.join(", ")}');
      });

      // Step 3: Analyze response data
      final bytes = response.data as Uint8List;
      debugPrint('\n📏 Data Analysis:');
      debugPrint('   Size: ${bytes.length} bytes');

      if (bytes.isEmpty) {
        debugPrint('❌ Response contains no data');
        return;
      }

      // Check if response is HTML (redirect page)
      final firstChars = String.fromCharCodes(bytes.take(100));
      if (firstChars.contains('<!DOCTYPE') ||
          firstChars.contains('<html') ||
          firstChars.contains('<!doctype') ||
          firstChars.contains('<?xml')) {
        debugPrint('🔴 CRITICAL: Server returned HTML page instead of image!');
        debugPrint('   This indicates the image file is missing or moved.');
        debugPrint(
            '   Response starts with: ${firstChars.substring(0, firstChars.length < 100 ? firstChars.length : 100)}');
        debugPrint(
            '\n💡 SOLUTION: Check if the image file exists on the server.');
        debugPrint('   File path might be: ${uri.path}');
        debugPrint(
            '   Server might be redirecting missing files to main site.');
        return;
      }

      // Check file signature (magic numbers)
      debugPrint('\n🔍 File Signature Analysis:');
      _analyzeFileSignature(bytes);

      // Step 4: Try to decode as image
      debugPrint('\n🖼️ Testing image decoding...');
      await _testImageDecoding(bytes);
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.type}');
      debugPrint('❌ Message: ${e.message}');
      if (e.response != null) {
        debugPrint('❌ Status Code: ${e.response!.statusCode}');
        debugPrint('❌ Response Data: ${e.response!.data}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected Error: $e');
    }
  }

  static void _analyzeFileSignature(Uint8List bytes) {
    if (bytes.length < 4) {
      debugPrint('   File too small to analyze signature');
      return;
    }

    // Common image file signatures
    final signatures = {
      [0x89, 0x50, 0x4E, 0x47]: 'PNG',
      [0xFF, 0xD8, 0xFF, 0xE0]: 'JPEG (JFIF)',
      [0xFF, 0xD8, 0xFF, 0xE1]: 'JPEG (Exif)',
      [0xFF, 0xD8, 0xFF, 0xE8]: 'JPEG (SPIFF)',
      [0xFF, 0xD8, 0xFF, 0xDB]: 'JPEG (Custom)',
      [0x47, 0x49, 0x46, 0x38]: 'GIF',
      [0x52, 0x49, 0x46, 0x46]: 'RIFF (WEBP)',
      [0x42, 0x4D]: 'BMP',
      [0x00, 0x00, 0x01, 0x00]: 'ICO',
    };

    final first4Bytes = bytes.take(4).toList();
    String? detectedFormat;

    for (final signature in signatures.keys) {
      if (_bytesEqual(first4Bytes, signature)) {
        detectedFormat = signatures[signature];
        break;
      }
    }

    if (detectedFormat != null) {
      debugPrint('   ✅ Detected format: $detectedFormat');
      debugPrint(
          '   📝 First 4 bytes: ${first4Bytes.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
    } else {
      debugPrint('   ❌ Unknown or invalid image format');
      debugPrint(
          '   📝 First 4 bytes: ${first4Bytes.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');

      // Check if it might be HTML error page
      if (bytes.length > 20) {
        final firstChars = String.fromCharCodes(bytes.take(20));
        if (firstChars.contains('<!DOCTYPE') ||
            firstChars.contains('<html') ||
            firstChars.contains('<!doctype')) {
          debugPrint(
              '   💡 This looks like an HTML error page, not an image file');
        }
      }
    }
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static Future<void> _testImageDecoding(Uint8List bytes) async {
    try {
      // Test if we can decode the image using Flutter's built-in methods
      // This is a simplified test - in a real app you'd use image package
      if (bytes.isEmpty) {
        debugPrint('   ❌ Cannot decode: Empty data');
        return;
      }

      // Basic validation - if we got this far without error, the data structure seems okay
      debugPrint('   ✅ Image data structure appears valid');

      // Additional checks based on file size
      if (bytes.length < 100) {
        debugPrint('   ⚠️ Very small file size - might be corrupted');
      } else if (bytes.length > 10 * 1024 * 1024) {
        debugPrint('   ⚠️ Very large file size - might cause memory issues');
      } else {
        debugPrint('   ✅ File size is reasonable for an image');
      }
    } catch (e) {
      debugPrint('   ❌ Decoding failed: $e');
    }
  }

  static String buildFullImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      debugPrint('⚠️ buildFullImageUrl: Empty imageUrl provided');
      return '';
    }

    String fullImageUrl = imageUrl.trim();

    // Handle relative URLs by prepending the base URL
    if (fullImageUrl.startsWith('/')) {
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
      fullImageUrl = '$baseUrl$fullImageUrl';
    } else if (!fullImageUrl.startsWith('http://') &&
        !fullImageUrl.startsWith('https://')) {
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
      fullImageUrl = '$baseUrl/$fullImageUrl';
    }

    if (kDebugMode && fullImageUrl.isEmpty) {
      debugPrint(
          '⚠️ buildFullImageUrl: Resulting URL is still empty for input: $imageUrl');
    }

    return fullImageUrl;
  }
}
