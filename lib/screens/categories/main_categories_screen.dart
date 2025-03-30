import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';
import 'subcategories_screen.dart';

class MainCategoriesScreen extends StatefulWidget {
  const MainCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<MainCategoriesScreen> createState() => _MainCategoriesScreenState();
}

class _MainCategoriesScreenState extends State<MainCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when the screen is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadMainCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 0,
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
                  Text(
                    categoryProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      categoryProvider.loadMainCategories();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final categories = categoryProvider.mainCategories;
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories found'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubcategoriesScreen(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (category.icon != null)
                Icon(
                  IconData(
                    int.parse(category.icon!),
                    fontFamily: 'MaterialIcons',
                  ),
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (category.productsCount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${category.productsCount} products',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
