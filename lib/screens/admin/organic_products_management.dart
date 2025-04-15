import 'package:flutter/material.dart';
import 'package:masoko_tips/models/organic_product.dart';
import 'package:masoko_tips/providers/admin_provider.dart';
import 'package:masoko_tips/screens/organic/edit_organic_product_screen.dart';
import 'package:masoko_tips/theme/app_theme.dart';
import 'package:masoko_tips/widgets/custom_app_bar.dart';
import 'package:masoko_tips/widgets/custom_drawer.dart';
import 'package:masoko_tips/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:masoko_tips/utils/log.dart';

class OrganicProductsManagementScreen extends StatefulWidget {
  const OrganicProductsManagementScreen({super.key});

  @override
  State<OrganicProductsManagementScreen> createState() =>
      _OrganicProductsManagementScreenState();
}

class _OrganicProductsManagementScreenState
    extends State<OrganicProductsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadOrganicProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Organic Products Management',
        automaticallyImplyLeading: true,
      ),
      drawer: const CustomDrawer(),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    adminProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadOrganicProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = adminProvider.organicProducts;
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No organic products found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a new organic product to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToEditProduct(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadOrganicProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                Log.d('Product Data: $product');
                Log.d('Product Seller: ${product.seller}');
                Log.d('Product Category: ${product.category}');
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () =>
                        _navigateToEditProduct(context, product: product),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: product.isActive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  product.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: product.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.attach_money,
                                label:
                                    'Price: ${product.price.toStringAsFixed(2)}',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.inventory,
                                label: 'Stock: ${product.stock}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.person,
                                label:
                                    'Seller: ${product.seller?['name'] ?? 'Unknown'}',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.category,
                                label:
                                    product.category?['name'] ?? 'No Category',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.verified,
                                label:
                                    product.certification ?? 'No Certification',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.location_on,
                                label: product.origin ?? 'No Origin',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.calendar_today,
                                label:
                                    'Harvest: ${product.harvestDate?.toString().split(' ')[0] ?? 'N/A'}',
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                icon: Icons.timer,
                                label:
                                    'Shelf Life: ${product.shelfLife ?? 'N/A'}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInfoChip(
                            icon: Icons.storage,
                            label:
                                'Storage: ${product.storageConditions ?? 'N/A'}',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Updated: ${DateFormat('MMM d, y').format(product.updatedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _navigateToEditProduct(
                                        context,
                                        product: product),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _confirmDelete(context, product),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditProduct(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProduct(BuildContext context, {OrganicProduct? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrganicProductScreen(product: product),
      ),
    ).then((_) => context.read<AdminProvider>().loadOrganicProducts());
  }

  void _confirmDelete(BuildContext context, OrganicProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context
                    .read<AdminProvider>()
                    .deleteOrganicProduct(product.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
