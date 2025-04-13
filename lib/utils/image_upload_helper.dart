import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// A utility class to help with image uploads across the app
class ImageUploadHelper {
  /// Picks an image from the gallery and returns an XFile object
  static Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        print('Web image selected: ${pickedFile.path}');
        print('Web image name: ${pickedFile.name}');
        print('Web image mime type: ${pickedFile.mimeType}');
      } else {
        print('Mobile/desktop image selected: ${pickedFile.path}');
      }

      return pickedFile;
    }

    return null;
  }

  /// Prepares an image file for upload in a multipart request
  static Future<http.MultipartFile> prepareImageForUpload(
      XFile imageFile) async {
    if (kIsWeb) {
      // Web environment handling
      print('Preparing web image for upload: ${imageFile.path}');

      if (imageFile.path.startsWith('blob:')) {
        // For blob URLs, we need to fetch the actual image data
        print('Blob URL detected: ${imageFile.path}');

        try {
          print('Attempting to fetch blob data using http.get...');
          final response = await http.get(Uri.parse(imageFile.path));

          if (response.statusCode != 200) {
            throw Exception('Failed to fetch blob URL: ${response.statusCode}');
          }

          // Check if response body is empty
          if (response.bodyBytes.isEmpty) {
            print('Warning: Empty response body from blob URL');
            throw Exception('Empty image data received from blob URL');
          }

          // Get the content type from response headers
          final contentType = response.headers['content-type'] ?? 'image/png';
          print('Content type from headers: $contentType');

          final parts = contentType.split('/');
          final mediaType = MediaType(parts[0], parts[1]);

          // Create a filename with the correct extension
          final extension = mediaType.subtype;
          final fileName =
              'image_${DateTime.now().millisecondsSinceEpoch}.$extension';

          print(
              'Creating multipart file with ${response.bodyBytes.length} bytes and filename: $fileName');

          return http.MultipartFile.fromBytes(
            'image',
            response.bodyBytes,
            filename: fileName,
            contentType: mediaType,
          );
        } catch (e) {
          print('Error fetching blob URL: $e');
          throw Exception('Failed to process blob URL: $e');
        }
      } else {
        try {
          // Try to fetch the image data from the URL
          print('Trying to fetch from regular URL...');
          final response = await http.get(Uri.parse(imageFile.path));

          if (response.statusCode != 200) {
            throw Exception(
                'Failed to fetch image from URL: ${response.statusCode}');
          }

          if (response.bodyBytes.isEmpty) {
            throw Exception('Empty image data received from URL');
          }

          // Get the content type from the response headers
          final contentType = response.headers['content-type'] ?? 'image/jpeg';
          final parts = contentType.split('/');
          final mediaType = MediaType(parts[0], parts[1]);

          // Create a filename with the correct extension
          final extension = mediaType.subtype;
          final fileName =
              'image_${DateTime.now().millisecondsSinceEpoch}.$extension';

          print(
              'Creating multipart file with ${response.bodyBytes.length} bytes');

          return http.MultipartFile.fromBytes(
            'image',
            response.bodyBytes,
            filename: fileName,
            contentType: mediaType,
          );
        } catch (e) {
          print('Error fetching image URL: $e');
          throw Exception('Failed to process image URL: $e');
        }
      }
    } else {
      // Mobile/desktop environment handling
      print('Preparing mobile/desktop image for upload: ${imageFile.path}');

      // Get file extension from path
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          'image_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Determine content type based on file extension
      String contentType;
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        default:
          contentType = 'image/jpeg';
      }

      final parts = contentType.split('/');
      final mediaType = MediaType(parts[0], parts[1]);

      // Read the file as bytes
      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Image file is empty');
      }

      print(
          'Mobile/desktop image prepared: ${bytes.length} bytes, type: $contentType');

      return http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: fileName,
        contentType: mediaType,
      );
    }
  }
}
