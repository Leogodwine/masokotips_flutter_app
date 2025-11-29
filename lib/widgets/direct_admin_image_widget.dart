import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../utils/image_diagnostic.dart';

/// Specialized image widget for DirectAdmin + Laravel Separation setup
/// Handles the complex folder structure where Laravel core is outside web root
class DirectAdminImageWidget extends StatelessWidget {
  final String imagePath; // Path relative to storage/app/public/
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final bool enableDiagnostic;

  const DirectAdminImageWidget({
    Key? key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.enableDiagnostic = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      debugPrint('⚠️ Image path is empty, showing placeholder');
      return errorWidget?.call(context, imagePath, 'Empty path') ??
          _buildDefaultPlaceholder('No image path', context);
    }

    // Build DirectAdmin-compatible URL
    String imageUrl = buildDirectAdminImageUrl(imagePath);

    debugPrint('🖥️ DirectAdmin Image URL: $imageUrl');
    debugPrint('📁 Original path: $imagePath');

    // Validate URL format
    try {
      final uri = Uri.parse(imageUrl);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        throw Exception('Invalid URL scheme: ${uri.scheme}');
      }
    } catch (e) {
      debugPrint('❌ Invalid image URL: $imageUrl, Error: $e');
      return errorWidget?.call(context, imageUrl, e) ??
          _buildDefaultPlaceholder('Invalid image URL', context);
    }

    // Run diagnostic if enabled
    if (enableDiagnostic && kDebugMode) {
      ImageDiagnostic.diagnoseImageUrl(imageUrl);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
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
        debugPrint('❌ DirectAdmin Error loading image from URL: $url');
        debugPrint('❌ Error details: $error');

        String errorMessage = 'Failed to load image';
        String debugInfo = '';

        // Provide specific error messages for DirectAdmin setup
        if (error.toString().contains('302') ||
            error.toString().contains('redirect')) {
          errorMessage = 'Image not found (redirect)';
          debugInfo =
              'Check file exists in storage and storage link is configured';
        } else if (error.toString().contains('EncodingError')) {
          errorMessage = 'Invalid image format';
          debugInfo = 'Server may be returning HTML instead of image';
        } else if (error.toString().contains('404')) {
          errorMessage = 'Image not found';
          debugInfo = 'File may not exist or storage link is broken';
        }

        if (kDebugMode && debugInfo.isNotEmpty) {
          debugPrint('💡 DirectAdmin Debug: $debugInfo');
        }

        return errorWidget?.call(context, imageUrl, error) ??
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

  /// Build DirectAdmin + Laravel separation compatible URL
  /// Assumes structure: domain.com/storage/{relative-path}
  static String buildDirectAdminImageUrl(String imagePath) {
    // Remove 'storage/' prefix if present to avoid duplication
    String cleanPath =
        imagePath.replaceFirst('storage/', '').replaceFirst('app/public/', '');

    // Build DirectAdmin URL structure
    // Assuming your domain is configured in ApiConfig
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$baseUrl/storage/$cleanPath';
  }

  /// Alternative URL builder for direct Laravel backend access
  /// Use this if storage link is not working
  static String buildLaravelBackendImageUrl(String imagePath) {
    String cleanPath =
        imagePath.replaceFirst('storage/', '').replaceFirst('app/public/', '');
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$baseUrl/laravel-backend/public/storage/$cleanPath';
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

/// Extension for easier usage
extension DirectAdminImageExtensions on String {
  /// Convert storage path to DirectAdmin URL
  String toDirectAdminImageUrl() {
    return DirectAdminImageWidget.buildDirectAdminImageUrl(this);
  }

  /// Convert storage path to Laravel backend URL
  String toLaravelBackendImageUrl() {
    return DirectAdminImageWidget.buildLaravelBackendImageUrl(this);
  }
}
