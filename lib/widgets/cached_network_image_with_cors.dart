import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class CachedNetworkImageWithCors extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const CachedNetworkImageWithCors({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If imageUrl is null or empty, return a placeholder immediately.
    if (imageUrl.isEmpty) {
      return errorWidget?.call(context, imageUrl, 'Empty URL') ??
          Container(
            height: height ?? 160,
            width: width ?? double.infinity,
            color: Colors.grey[100],
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: Colors.grey,
              ),
            ),
          );
    }
    // Handle relative URLs by prepending the base URL
    String fullImageUrl = imageUrl;
    if (imageUrl.startsWith('/')) {
      // Remove '/api' from base URL to get the domain
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
      fullImageUrl = '$baseUrl$imageUrl';
    } else if (!imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://')) {
      // Handle relative URLs that don't start with '/' (like "organic-products/filename.jpg")
      final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
      fullImageUrl = '$baseUrl/$imageUrl';
    }

    // Validate URL format
    try {
      final uri = Uri.parse(fullImageUrl);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        throw Exception('Invalid URL scheme: ${uri.scheme}');
      }
      if (uri.host.isEmpty) {
        throw Exception('Empty host in URL');
      }
    } catch (e) {
      debugPrint('❌ Invalid image URL format: $fullImageUrl, Error: $e');
      return errorWidget?.call(context, fullImageUrl, e) ??
          Container(
            height: height ?? 160,
            width: width ?? double.infinity,
            color: Colors.grey[100],
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: Colors.grey,
              ),
            ),
          );
    }

    debugPrint('✅ Attempting to load image from URL: $fullImageUrl');

    // Skip validation for now due to backend issues, proceed directly with CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: (context, url, error) {
        debugPrint('❌ Error loading image from URL: $url');
        debugPrint('❌ Error details: $error');
        debugPrint('❌ Error type: ${error.runtimeType}');
        if (error is Exception) {
          debugPrint('❌ Exception message: ${error.toString()}');
        }

        String errorMessage = 'Failed to load image';
        if (error.toString().contains('500')) {
          errorMessage = 'Server error - image unavailable';
        } else if (error.toString().contains('404')) {
          errorMessage = 'Image not found';
        } else if (error.toString().contains('403') ||
            error.toString().contains('401')) {
          errorMessage = 'Access denied to image';
        }

        return errorWidget?.call(context, fullImageUrl, error) ??
            Container(
              height: height ?? 160,
              width: width ?? double.infinity,
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image_not_supported_outlined,
                      size: 32,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
      },
      httpHeaders: const {
        'Accept': 'image/*',
        'Cache-Control': 'no-cache',
      },
      memCacheWidth: 800,
      memCacheHeight: 800,
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 800,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }
}
