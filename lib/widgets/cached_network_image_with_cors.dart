import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/image_diagnostic.dart';

class CachedNetworkImageWithCors extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final bool enableDiagnostic;

  const CachedNetworkImageWithCors({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.enableDiagnostic = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If imageUrl is null or empty, return a placeholder immediately.
    if (imageUrl.isEmpty) {
      debugPrint('⚠️ Image URL is empty, showing placeholder');
      return errorWidget?.call(context, imageUrl, 'Empty URL') ??
          _buildDefaultPlaceholder('No image', context);
    }

    // Handle relative URLs by prepending the base URL
    String fullImageUrl = ImageDiagnostic.buildFullImageUrl(imageUrl);

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
          _buildDefaultPlaceholder('Invalid image URL', context);
    }

    if (kDebugMode) {
      debugPrint('✅ Attempting to load image from URL: $fullImageUrl');
    }

    // Run diagnostic if enabled
    if (enableDiagnostic && kDebugMode) {
      ImageDiagnostic.diagnoseImageUrl(fullImageUrl);
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ??
          (context, url) => Container(
                height: height ?? 160,
                width: width ?? double.infinity,
                color: Colors.grey[100],
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Loading image...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      errorWidget: (context, url, error) {
        if (kDebugMode) {
          debugPrint('❌ Error loading image from URL: $url');
          debugPrint('❌ Error details: $error');
          debugPrint('❌ Error type: ${error.runtimeType}');
          if (error is Exception) {
            debugPrint('❌ Exception message: ${error.toString()}');
          }
        }

        String errorMessage = 'Failed to load image';
        String debugInfo = '';

        if (error.toString().contains('500')) {
          errorMessage = 'Server error - image unavailable';
        } else if (error.toString().contains('404')) {
          errorMessage = 'Image not found';
        } else if (error.toString().contains('403') ||
            error.toString().contains('401')) {
          errorMessage = 'Access denied to image';
        } else if (error.toString().contains('EncodingError')) {
          errorMessage = 'Invalid image format';
          debugInfo =
              'The image file may be corrupted or in an unsupported format';
        } else if (error.toString().contains('timeout')) {
          errorMessage = 'Loading timeout';
          debugInfo = 'The image is taking too long to load';
        }

        // Provide actionable debug info (only in debug mode and for critical errors)
        if (kDebugMode &&
            debugInfo.isNotEmpty &&
            errorMessage.contains('timeout')) {
          debugPrint('💡 Debug Info: $debugInfo');
        }

        return errorWidget?.call(context, fullImageUrl, error) ??
            _buildErrorPlaceholder(errorMessage, debugInfo, context);
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

  Widget _buildDefaultPlaceholder(String message, BuildContext context) {
    return Container(
      height: height ?? 160,
      width: width ?? double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.webp',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: Colors.grey,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(
      String message, String debugInfo, BuildContext context) {
    return Container(
      height: height ?? 160,
      width: width ?? double.infinity,
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.webp',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported_outlined,
                  size: 32,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            if (debugInfo.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                debugInfo,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
