import 'package:flutter/material.dart';
import '../products/product_list_screen.dart';
import '../services/transport_service_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CategoryListScreen extends StatelessWidget {
  final int categoryId;
  final String title;
  final List<String> subcategories;

  const CategoryListScreen({
    super.key,
    required this.categoryId,
    required this.title,
    required this.subcategories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: subcategories.length,
          itemBuilder: (context, index) {
            final subcategory = subcategories[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        _getIconForSubcategory(subcategory),
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        subcategory,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _getSubcategoryDescription(subcategory),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (title == 'Transport') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransportServiceScreen(
                                transportType: subcategory,
                                transportDetails: {
                                  'imageUrl':
                                      'https://via.placeholder.com/400x200',
                                  'isAvailable': true,
                                  'description':
                                      'Professional ${subcategory.toLowerCase()} transport service for your needs',
                                  'serviceAreas': const [
                                    'Urban Areas',
                                    'Rural Areas',
                                    'Interstate'
                                  ],
                                  'specifications': {
                                    'Capacity': '10 tons',
                                    'Vehicle Type': subcategory,
                                    'Coverage': 'Nationwide',
                                    'Service Type': 'Commercial Transport',
                                  },
                                  'baseRate': 2.5,
                                  'minDistance': 5,
                                  'additionalCharges':
                                      'Loading/Unloading fees may apply',
                                  'providerName': '$subcategory Pro Services',
                                  'providerImage':
                                      'https://via.placeholder.com/100',
                                  'providerDescription':
                                      'Professional ${subcategory.toLowerCase()} transport service provider with years of experience',
                                  'providerPhone': '+254700000000',
                                  'providerEmail': 'transport@example.com',
                                },
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListScreen(
                                title: title,
                                categoryId: categoryId,
                                subcategory: subcategory,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForSubcategory(String subcategory) {
    switch (subcategory.toLowerCase()) {
      case 'tandem':
        return Icons.local_shipping;
      case 'kirikuu':
        return Icons.fire_truck;
      case 'flatbedtrucks':
        return Icons.local_shipping;
      case 'tanker':
        return Icons.local_shipping;
      case 'refrigerator truck':
        return Icons.ac_unit;
      case 'box truck':
        return Icons.inventory_2;
      case 'liftgate truck':
        return Icons.elevator;
      case 'van':
        return Icons.airport_shuttle;
      case 'container hauler':
        return Icons.local_shipping;
      case 'pickups trucks':
        return Icons.local_shipping;
      case 'fuso':
        return Icons.local_shipping;
      case 'semi trailers':
        return Icons.local_shipping;
      case 'tracker trailers':
        return Icons.local_shipping;
      // Product categories
      case 'vegetables':
        return Icons.eco;
      case 'fruits':
        return Icons.apple;
      case 'spices':
        return Icons.spa;
      case 'cash crops':
        return Icons.monetization_on;
      case 'cereals':
        return Icons.grain;
      case 'seeds and seedling':
        return Icons.local_florist;
      case 'livestock and poultry':
        return Icons.pets;
      default:
        return Icons.category;
    }
  }

  String _getSubcategoryDescription(String subcategory) {
    switch (subcategory.toLowerCase()) {
      case 'tandem':
        return 'Large capacity trucks for bulk transportation';
      case 'kirikuu':
        return 'Medium-sized trucks for urban and inter-city deliveries';
      case 'flatbedtrucks':
        return 'Open bed trucks for oversized cargo';
      case 'tanker':
        return 'Specialized trucks for liquid transportation';
      case 'refrigerator truck':
        return 'Temperature-controlled transport for perishable goods';
      case 'box truck':
        return 'Enclosed cargo space for secure transportation';
      case 'liftgate truck':
        return 'Trucks with hydraulic lift for easy loading/unloading';
      case 'van':
        return 'Smaller vehicles for quick deliveries';
      case 'container hauler':
        return 'Heavy-duty trucks for container transport';
      case 'pickups trucks':
        return 'Versatile vehicles for smaller loads';
      case 'fuso':
        return 'Reliable trucks for medium to heavy loads';
      case 'semi trailers':
        return 'Large capacity trailers for long-distance transport';
      case 'tracker trailers':
        return 'GPS-equipped trailers for real-time tracking';
      // Product categories
      case 'vegetables':
        return 'Fresh, locally sourced vegetables from trusted farmers';
      case 'fruits':
        return 'Sweet and nutritious fruits for your daily needs';
      case 'spices':
        return 'Premium quality spices to enhance your cooking';
      case 'cash crops':
        return 'High-value agricultural products for commercial farming';
      case 'cereals':
        return 'Nutritious grains and cereals for your daily meals';
      case 'seeds and seedling':
        return 'Quality seeds and seedlings for your farming needs';
      case 'livestock and poultry':
        return 'Healthy livestock and poultry products';
      default:
        return 'Browse items in this category';
    }
  }
}
