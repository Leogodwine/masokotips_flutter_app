import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/transport.dart';

class AdminTransportManagementScreen extends StatefulWidget {
  const AdminTransportManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminTransportManagementScreen> createState() =>
      _AdminTransportManagementScreenState();
}

class _AdminTransportManagementScreenState
    extends State<AdminTransportManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().loadTransports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add transport screen
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
                      adminProvider.loadTransports();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final transports = adminProvider.transports;
          if (transports.isEmpty) {
            return const Center(child: Text('No transports found'));
          }

          return ListView.builder(
            itemCount: transports.length,
            itemBuilder: (context, index) {
              final transport = transports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: transport.imageUrl != null
                      ? Image.network(
                          transport.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(transport.name),
                  subtitle: Text(
                    'Type: ${transport.type}\n'
                    'Capacity: ${transport.capacity}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          // TODO: Navigate to edit transport screen
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, transport);
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

  void _showDeleteConfirmation(BuildContext context, Transport transport) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transport'),
        content: Text('Are you sure you want to delete ${transport.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await context
                  .read<AdminProvider>()
                  .deleteTransport(transport.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transport deleted successfully'),
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
}
