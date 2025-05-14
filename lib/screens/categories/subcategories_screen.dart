import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';
import '../products/category_products_screen.dart';


class SubcategoriesScreen extends StatefulWidget {
  final Category category;

  const SubcategoriesScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<SubcategoriesScreen> createState() => _SubcategoriesScreenState();
}

class _SubcategoriesScreenState extends State<SubcategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadSubcategories(widget.category.id);
    });
  }

  String _getCategoryImage(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'products':
        return 'assets/images/cereals.png';
      case 'spices':
        return 'assets/images/spices.png';
      case 'cash crops':
        return 'assets/images/cash_crops.png';
      case 'cereals':
        return 'assets/images/cereals.png';
      case 'organic products':
        return 'assets/images/vegetables.png';
      case 'fruits':
        return 'assets/images/fruits.png';
      case 'vegetables':
        return 'assets/images/vegetables.png';
      case 'grains':
        return 'assets/images/grains.png';
      case 'livestock and poultry':
        return 'assets/images/livestock_and_poultry.png';
      case 'seeds and seedling':
        return 'assets/images/seed.png';
      case 'seeds':
        return 'assets/images/seeds.png';

        //Organic Products
      case 'organic vegetables':
        return 'assets/images/vegetables.png';
      case 'organic fruits':
        return 'assets/images/fruits.png';
      case 'organic cereals':
        return 'assets/images/cereals.png';
      case 'organic spices':
        return 'assets/images/spices.png';
      case 'organic cash crops':
        return 'assets/images/cash_crops.png';
      case 'organic grains':
        return 'assets/images/grains.png';
      case 'organic seeds':
        return 'assets/images/seeds.png';
      case 'organic livestock and poultry':
        return 'assets/images/livestock_and_poultry.png';

        //Transport
      case 'tandem':
        return 'assets/images/tandum.png';
      case 'kirikuu':
        return 'assets/images/kirikuu.png';
      case 'flatbed trucks':
        return 'assets/images/flatbed.png';
      case 'tanker':
        return 'assets/images/tanker.png';
      case 'refrigerator truck':
        return 'assets/images/refrigerated.png';
      case 'box truck':
        return 'assets/images/box_truck.png';
      case 'liftgate truck':
        return 'assets/images/liftgate.png';
      case 'van':
        return 'assets/images/van.png';
      case 'container hauler':
        return 'assets/images/container.png';
      case 'pickups trucks':
        return 'assets/images/pickup.png';
      case 'fuso':
        return 'assets/images/fuso.png';
      case 'semi trailers':
        return 'assets/images/semi_trailers.png';
      case 'tracker trailers':
        return 'assets/images/tractor_trailers.png';

    //Agricultural Services
      case 'packaging materials':
        return 'assets/images/packaging.png';

      case 'hydroponics':
        return 'assets/images/irrigation.png';

      case 'fertilizer':
        return 'assets/images/fertilizer.png';

      case 'organic manure':
        return 'assets/images/organic_manure.png';

      case 'irrigation services':
        return 'assets/images/irrigation.png';

      case 'machinery':
        return 'assets/images/tanker.png';

      case 'beehive and aquatic':
        return 'assets/images/beehive.png';

      case 'food and beverage':
        return 'assets/images/fruits.png';

      case 'cold rooms services':
        return 'assets/images/cold_rooms.png';

      case 'machinery and rental services':
        return 'assets/images/machinery_rental.jpg';

      case 'financial services':
        return 'assets/images/financial.png';

      case 'branding and consultation services':
        return 'assets/images/branding.png';

      case 'agronomist services':
        return 'assets/images/vegetables.png';

      

          default:
        return 'assets/images/default.png';
    }
  }

  Widget _buildSubcategoryCard(Category subcategory) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxWidth * 0.35;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProductsScreen(
                    categoryId: subcategory.id,
                    categoryName: subcategory.name,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min, // 👈 prevents Column from expanding beyond needed height
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _getCategoryImage(subcategory.name),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subcategory.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 200 ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(categoryProvider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      categoryProvider.loadSubcategories(widget.category.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final subcategories = categoryProvider.subcategories;
          if (subcategories.isEmpty) {
            return CategoryProductsScreen(
              categoryId: widget.category.id,
              categoryName: widget.category.name,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subcategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // More height for content
            ),
            itemBuilder: (context, index) =>
                _buildSubcategoryCard(subcategories[index]),
          );
        },
      ),
    );
  }
}
