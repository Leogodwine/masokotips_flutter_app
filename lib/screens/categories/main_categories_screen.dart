import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';
import '../../widgets/app_scaffold.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadMainCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppLocalizations.of(context)!.categories,
      showBackButton: true,
      body: Container(
        color: Colors.grey[100],
        child: Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return _buildErrorState(
                  provider.error!, provider.loadMainCategories);
            }

            final categories = provider.mainCategories;
            if (categories.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)!.noCategoriesFound));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.95,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(context, categories[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    final theme = Theme.of(context);
    final iconData = _getIconData(category.icon);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubcategoriesScreen(category: category),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  size: 48,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (category.productsCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${category.productsCount} bidhaa',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.category;
    switch (iconName.toLowerCase()) {
      case 'shopping_basket':
        return Icons.shopping_basket;
      case 'miscellaneous_services':
        return Icons.miscellaneous_services;
      case 'trending_up':
        return Icons.trending_up;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'eco':
        return Icons.eco;
      case 'agriculture':
        return Icons.agriculture;
      case 'category':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}
