import 'package:flutter/material.dart';
import 'cached_network_image_with_cors.dart';

class ImageLoaderWithRetry extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int maxRetries;
  final Duration retryDelay;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const ImageLoaderWithRetry({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  ImageLoaderWithRetryState createState() => ImageLoaderWithRetryState();
}

class ImageLoaderWithRetryState extends State<ImageLoaderWithRetry> {
  int _retryCount = 0;
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImageWithCors(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder,
      errorWidget: (context, url, error) {
        if (_retryCount < widget.maxRetries && !_isRetrying) {
          _isRetrying = true;
          _retryCount++;

          Future.delayed(widget.retryDelay * _retryCount, () {
            if (mounted) {
              setState(() {
                _isRetrying = false;
              });
            }
          });

          return _buildRetryWidget(context);
        }

        // Max retries reached, show final error state
        return widget.errorWidget?.call(context, url, error) ??
            _buildFinalErrorWidget(context, url, error);
      },
    );
  }

  Widget _buildRetryWidget(BuildContext context) {
    return Container(
      height: widget.height ?? 160,
      width: widget.width ?? double.infinity,
      color: Colors.grey[100],
      child: Column(
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
            'Retrying... ($_retryCount/${widget.maxRetries})',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalErrorWidget(
      BuildContext context, String url, dynamic error) {
    return Container(
      height: widget.height ?? 160,
      width: widget.width ?? double.infinity,
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
            'Failed to load image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Max retries reached',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 32),
            ),
            onPressed: () {
              setState(() {
                _retryCount = 0;
                _isRetrying = false;
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
