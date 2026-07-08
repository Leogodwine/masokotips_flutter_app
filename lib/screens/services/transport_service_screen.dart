import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class TransportServiceScreen extends StatelessWidget {
  final String transportType;
  final Map<String, dynamic> transportDetails;

  const TransportServiceScreen({
    Key? key,
    required this.transportType,
    required this.transportDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transportType),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            CachedNetworkImage(
              imageUrl: transportDetails['imageUrl'] as String,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey.withAlpha(26),
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey.withAlpha(26),
                child: const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Availability Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: transportDetails['isAvailable'] as bool
                          ? Colors.green.withAlpha(26)
                          : Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      transportDetails['isAvailable'] as bool
                          ? 'Available'
                          : 'Not Available',
                      style: TextStyle(
                        color: transportDetails['isAvailable'] as bool
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transportDetails['description'] as String,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // Pricing Information
                  Text(
                    'Pricing Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Base Rate per KM',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('\$${transportDetails['baseRate']}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Minimum Distance',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${transportDetails['minDistance']} KM'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Additional Charges:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(transportDetails['additionalCharges'] as String),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Ensure proper type conversion for price calculation
            final double baseRate =
                (transportDetails['baseRate'] as num).toDouble();
            final double minDistance =
                (transportDetails['minDistance'] as num).toDouble();

            // Create a product from transport service
            final product = Product(
              id: DateTime.now().millisecondsSinceEpoch,
              name: '$transportType Service',
              description: transportDetails['description'] as String,
              price: baseRate * minDistance,
              stock: 1,
              isActive: true,
              isFeatured: false,
              categoryId: 0,
              userId: 0,
              images: [transportDetails['imageUrl'] as String],
              rating: 0,
              ratingCount: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              slug: '$transportType-service'.toLowerCase().replaceAll(' ', '-'),
              imageUrl: transportDetails['imageUrl'] as String,
            );

            context.read<CartProvider>().addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.serviceAddedToCart),
                action: SnackBarAction(
                  label: 'VIEW CART',
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              ),
            );
          },
          child: Text(AppLocalizations.of(context)!.bookTransportService),
        ),
      ),
    );
  }
}
