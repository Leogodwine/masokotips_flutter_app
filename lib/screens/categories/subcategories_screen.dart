import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/category_provider.dart';
import '../../providers/cart_provider.dart';
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
      debugPrint(
          'SubcategoriesScreen: Loading subcategories for category ${widget.category.id} (${widget.category.name})');
      context.read<CategoryProvider>().loadSubcategories(widget.category.id);
    });
  }

  String _getLocalizedCategoryName(String categoryName) {
    // Map common category names to localized versions
    switch (categoryName.toLowerCase()) {
      case 'products':
        return 'Bidhaa'; // Kiswahili for Products
      case 'services':
        return AppLocalizations.of(context)?.services ??
            'Huduma'; // Kiswahili for Services
      case 'transport':
        return 'Usafiri'; // Kiswahili for Transport
      case 'organic products':
        return 'Bidhaa za Oganiki'; // Kiswahili for Organic Products
      case 'agricultural services':
        return 'Huduma za Kilimo'; // Kiswahili for Agricultural Services
      default:
        return categoryName;
    }
  }

  String _getCategoryImage(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'products':
        return 'assets/images/cereals.webp';
      case 'spices':
        return 'assets/images/spices.webp';
      case 'cash crops':
        return 'assets/images/cash_crops.webp';
      case 'cereals':
        return 'assets/images/cereals.webp';
      case 'organic products':
        return 'assets/images/vegetables.webp';
      case 'fruits':
        return 'assets/images/vegetables.webp';
      case 'vegetables':
        return 'assets/images/vegetables.webp';
      case 'grains':
        return 'assets/images/cereals.webp';
      case 'livestock and poultry':
        return 'assets/images/livestock_and_poultry.webp';
      case 'seeds and seedling':
        return 'assets/images/seed.webp';
      case 'seeds':
        return 'assets/images/seed.webp';

      //Organic Products
      case 'organic vegetables':
        return 'assets/images/vegetables.webp';
      case 'organic fruits':
        return 'assets/images/organic_fruits.png';
      case 'organic cereals':
        return 'assets/images/cereals.webp';
      case 'organic spices':
        return 'assets/images/spices.webp';
      case 'organic cash crops':
        return 'assets/images/cash_crops.webp';
      case 'organic grains':
        return 'assets/images/cereals.webp';
      case 'organic seeds':
        return 'assets/images/seed.webp';
      case 'organic livestock and poultry':
        return 'assets/images/livestock_and_poultry.webp';

      //Transport
      case 'tandem':
        return 'assets/images/tandum.webp';
      case 'kirikuu':
        return 'assets/images/kirikuu.png';
      case 'flatbed trucks':
        return 'assets/images/flatbed.webp';
      case 'tanker':
        return 'assets/images/tanker.webp';
      case 'refrigerator truck':
        return 'assets/images/refrigerated.webp';
      case 'box truck':
        return 'assets/images/box_truck.webp';
      case 'liftgate truck':
        return 'assets/images/liftgate.webp';
      case 'van':
        return 'assets/images/van.webp';
      case 'container hauler':
        return 'assets/images/container.webp';
      case 'pickups trucks':
        return 'assets/images/pickup.webp';
      case 'fuso':
        return 'assets/images/fuso.png';
      case 'semi trailers':
        return 'assets/images/semi_trailers.png';
      case 'tracker trailers':
        return 'assets/images/tractor_trailers.png';
      case 'cargo':
        return 'assets/images/air_cargo.png';

      //Agricultural Services
      case 'packaging materials':
        return 'assets/images/packaging.webp';

      case 'hydroponics':
        return 'assets/images/hydroponics.png';

      case 'fertilizer':
        return 'assets/images/fertilizer.png';

      case 'organic manure':
        return 'assets/images/organic_manure.webp';

      case 'irrigation services':
        return 'assets/images/fertilizer.webp';

      case 'machinery':
        return 'assets/images/tractor.png';

      case 'beehive and aquatic':
        return 'assets/images/beehive.webp';

      case 'food and beverage':
        return 'assets/images/food_and_beverage.png';

      case 'cold rooms services':
        return 'assets/images/cold_rooms.webp';

      case 'machinery and rental services':
        return 'assets/images/machinery_rental.webp';

      case 'financial services':
        return 'assets/images/financial.webp';

      case 'branding and consultation services':
        return 'assets/images/branding.webp';

      case 'agronomist services':
        return 'assets/images/agronomist.png';

      //Food And Beverages
      case 'cooking oil':
        return 'assets/images/cooking_oil.png';

      case 'peanut butter':
        return 'assets/images/peanut_butter.png';

      case 'fermented milk':
        return 'assets/images/fermented_milk.png';

      case 'yogurt':
        return 'assets/images/yogurt.png';

      case 'wine':
        return 'assets/images/wine.png';

      default:
        return 'assets/images/default.webp';
    }
  }

  Widget _buildSubcategoryCard(Category subcategory) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(
                categoryId: subcategory.id,
                categoryName: subcategory.name,
                parentCategoryName: widget.category.name,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image container with better proportions
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      _getCategoryImage(subcategory.name),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title with better spacing
              Expanded(
                flex: 1,
                child: Text(
                  subcategory.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedCategoryName(widget.category.name)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
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
                  Text(categoryProvider.error!,
                      style: const TextStyle(color: Colors.red)),
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
          debugPrint(
              'SubcategoriesScreen: subcategories count: ${subcategories.length}');
          debugPrint('SubcategoriesScreen: subcategories: $subcategories');

          if (subcategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noCategoriesFound,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.checkBackLater,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('SubcategoriesScreen: Retry button pressed');
                      categoryProvider.loadSubcategories(widget.category.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subcategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85, // Optimized for new card design
            ),
            itemBuilder: (context, index) =>
                _buildSubcategoryCard(subcategories[index]),
          );
        },
      ),
    );
  }
}
