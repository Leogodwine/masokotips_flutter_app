import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/service.dart';
import 'service_management_screen.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class AdminServicesManagementScreen extends StatefulWidget {
  const AdminServicesManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminServicesManagementScreen> createState() =>
      _AdminServicesManagementScreenState();
}

class _AdminServicesManagementScreenState
    extends State<AdminServicesManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.servicesManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final adminProvider = context.read<AdminProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceManagementScreen(),
                ),
              ).then((_) {
                // Refresh services list after returning
                if (mounted) {
                  adminProvider.loadServices();
                }
              });
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
                      adminProvider.loadServices();
                    },
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          final services = adminProvider.services;
          if (services.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noServicesFound));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: service.imageUrl != null
                      ? Image.network(
                          service.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(service.title ?? 'No Title'),
                  subtitle: Text(
                    'Price: TZS ${service.price.toStringAsFixed(2)}\n'
                    'Category: ${service.subcategory ?? 'Uncategorized'}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          final adminProvider = context.read<AdminProvider>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ServiceManagementScreen(),
                            ),
                          ).then((_) {
                            // Refresh services list after returning
                            if (mounted) {
                              adminProvider.loadServices();
                            }
                          });
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, service);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(AppLocalizations.of(context)!.delete),
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

  void _showDeleteConfirmation(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteService),
        content: Text('Are you sure you want to delete ${service.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              final success =
                  await context.read<AdminProvider>().deleteService(service.id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.serviceDeletedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}
