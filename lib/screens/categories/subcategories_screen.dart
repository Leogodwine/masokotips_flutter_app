import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../products/product_list_screen.dart';

class SubcategoriesScreen extends StatelessWidget {
  final Category mainCategory;

  const SubcategoriesScreen({
    Key? key,
    required this.mainCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mainCategory.name),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: mainCategory.subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = mainCategory.subcategories[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListScreen(
                      title: subcategory.name,
                      categoryId: subcategory.id,
                      subcategory: subcategory.name,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getSubcategoryIcon(mainCategory.name, subcategory.name),
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subcategory.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getSubcategoryIcon(String mainCategory, String subcategoryName) {
    switch (mainCategory.toLowerCase()) {
      case 'products':
        switch (subcategoryName.toLowerCase()) {
          case 'vegetables':
            return Icons.eco_outlined;
          case 'fruits':
            return Icons.apple;
          case 'spices':
            return Icons.spa;
          case 'cash crops':
            return Icons.agriculture;
          case 'cereals':
            return Icons.grain;
          case 'seeds and seedling':
            return Icons.forest;
          case 'livestock and poultry':
            return Icons.pets;
          default:
            return Icons.category;
        }
      case 'transport':
        switch (subcategoryName.toLowerCase()) {
          case 'tandem':
            return Icons.local_shipping;
          case 'kirikuu':
            return Icons.delivery_dining;
          case 'flatbedtrucks':
            return Icons.local_shipping;
          case 'tanker':
            return Icons.water_drop;
          case 'refrigerator truck':
            return Icons.ac_unit;
          case 'box truck':
            return Icons.inbox;
          case 'liftgate truck':
            return Icons.elevator;
          case 'van':
            return Icons.directions_car;
          case 'container hauler':
            return Icons.inbox;
          case 'pickups trucks':
            return Icons.directions_car;
          case 'fuso':
            return Icons.local_shipping;
          case 'semi trailers':
            return Icons.local_shipping;
          case 'tracker trailers':
            return Icons.local_shipping;
          default:
            return Icons.local_shipping;
        }
      case 'organic products':
        switch (subcategoryName.toLowerCase()) {
          case 'organic vegetables':
            return Icons.eco;
          case 'organic fruits':
            return Icons.apple;
          case 'organic spices':
            return Icons.spa;
          case 'organic cash crops':
            return Icons.agriculture;
          case 'organic cereals':
            return Icons.grain;
          case 'organic livestock and poultry':
            return Icons.pets;
          default:
            return Icons.eco;
        }
      case 'other services':
        switch (subcategoryName.toLowerCase()) {
          case 'packaging materials':
            return Icons.inbox;
          case 'hydroponics':
            return Icons.water_drop;
          case 'fertilizer':
            return Icons.agriculture;
          case 'organic manure':
            return Icons.recycling;
          case 'machinery':
            return Icons.construction;
          case 'behive and aquatic':
            return Icons.water;
          case 'food and beverage':
            return Icons.restaurant;
          default:
            return Icons.miscellaneous_services;
        }
      default:
        return Icons.category;
    }
  }
}
