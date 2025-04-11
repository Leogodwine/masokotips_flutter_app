import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/organic_product.dart';

class AdminOrganicProductsManagementScreen extends StatefulWidget {
  const AdminOrganicProductsManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrganicProductsManagementScreen> createState() =>
      _AdminOrganicProductsManagementScreenState();
}

class _AdminOrganicProductsManagementScreenState
    extends State<AdminOrganicProductsManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().loadOrganicProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organic Products Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add organic product screen
            },
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${adminProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      adminProvider.loadOrganicProducts();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = adminProvider.organicProducts;
          if (products.isEmpty) {
            return const Center(child: Text('No organic products found'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(product.name),
                  subtitle: Text(
                    'Price: \$${product.price.toStringAsFixed(2)}\n'
                    'Category: ${_getCategoryName(product.categoryId)}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          // TODO: Navigate to edit organic product screen
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, product);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, OrganicProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organic Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await context
                  .read<AdminProvider>()
                  .deleteOrganicProduct(product.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Organic product deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(int categoryId) {
    final categoryMap = {
      1: 'Organic Vegetables',
      2: 'Organic Fruits',
      3: 'Organic Spices',
      4: 'Organic Cash Crops',
      5: 'Organic Cereals',
      6: 'Organic Livestock and Poultry',
    };
    return categoryMap[categoryId] ?? 'Unknown Category';
  }
}
