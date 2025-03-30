import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';
import '../products/category_products_screen.dart';
import 'package:masoko_tips/utils/logger.dart';

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
    // Load subcategories when the screen is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadSubcategories(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
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
            // If no subcategories, show products directly
            Log.e(
                'SubcategoriesScreen: No subcategories found, showing products directly');
            return CategoryProductsScreen(
              categoryId: widget.category.id,
              categoryName: widget.category.name,
            );
          }

          Log.e(
              'SubcategoriesScreen: Showing ${subcategories.length} subcategories');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(subcategory.name),
                  trailing: const Icon(Icons.arrow_forward_ios),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
