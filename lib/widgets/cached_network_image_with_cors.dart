import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    print('Attempting to load image from URL: $imageUrl');

    // Check image accessibility before building
    _checkImageAccessibility();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: (context, url, error) {
        print('Error loading image from URL: $url');
        print('Error details: $error');

        return errorWidget?.call(context, url, error) ??
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
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
      },
      httpHeaders: const {
        'Accept': 'image/*',
      },
    );
  }

  Future<void> _checkImageAccessibility() async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      print('HTTP Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body Length: ${response.bodyBytes.length}');
    } catch (e) {
      print('HTTP Request Error: $e');
    }
  }
}
