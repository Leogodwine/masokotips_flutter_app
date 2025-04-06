import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/service_service.dart';
import '../../models/service.dart';
import '../../widgets/error_handler.dart';
import '../agriculture/add_agricultural_service_screen.dart';
import '../../services/agriculture_service.dart';
import '../services/agricultural_services_screen.dart';

class ServiceProviderDashboardScreen extends StatefulWidget {
  const ServiceProviderDashboardScreen({super.key});

  @override
  State<ServiceProviderDashboardScreen> createState() =>
      _ServiceProviderDashboardScreenState();
}

class _ServiceProviderDashboardScreenState
    extends State<ServiceProviderDashboardScreen> {
  final ServiceService _serviceService = ServiceService();
  final AgricultureService _agricultureService = AgricultureService();
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null) {
      _serviceService.setAuthToken(authProvider.token!);
      _loadServices();
    }
  }

  Future<void> _loadServices() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final services = await _serviceService.getMyServices();
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteService(Service service) async {
    try {
      await _serviceService.deleteService(service.id.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
        _loadServices(); // Refresh the list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service: $e')),
      );
    }
  }

  Future<void> _openAddAgriculturalServiceScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add agricultural services'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate to login screen
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    // Set the auth token for the agriculture service
    _agricultureService.setAuthToken(authProvider.token!);

    // Navigate to add agricultural service screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAgriculturalServiceScreen(
            onServiceAdded: (service) {
              setState(() {
                _services.add(service);
              });
            },
            agricultureService: _agricultureService,
          ),
        ),
      );
    }
  }

  Future<void> _openAgriculturalServicesScreen() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token == null || authProvider.token!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to view agricultural services'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate to login screen
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    // Set the auth token for the agriculture service
    _agricultureService.setAuthToken(authProvider.token!);

    // Navigate to agricultural services screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AgriculturalServicesScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Services Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'View All Agricultural Services',
            onPressed: _openAgriculturalServicesScreen,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorHandler(
                  message: _error!,
                  onRetry: _loadServices,
                )
              : RefreshIndicator(
                  onRefresh: _loadServices,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Agricultural Services',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _openAgriculturalServicesScreen,
                                  icon: const Icon(Icons.list),
                                  label: const Text('View All'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[100],
                                    foregroundColor: Colors.green[800],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _openAddAgriculturalServiceScreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _services.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.agriculture_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No agricultural services yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add your first agricultural service to get started',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed:
                                          _openAddAgriculturalServiceScreen,
                                      icon: const Icon(Icons.add),
                                      label: const Text(
                                          'Add Agricultural Service'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _services.length,
                                itemBuilder: (context, index) {
                                  final service = _services[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      leading: service.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                service.imageUrl!,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Icon(
                                                Icons.agriculture,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      title: Text(service.title),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (service.subcategory != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Chip(
                                                label: Text(
                                                  service.subcategory!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                backgroundColor:
                                                    Colors.green[100],
                                                labelStyle: TextStyle(
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'edit':
                                              // Navigate to edit service screen
                                              Navigator.pushNamed(
                                                context,
                                                '/provider/edit-service',
                                                arguments: service,
                                              );
                                              break;
                                            case 'delete':
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Delete Service'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this service?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('CANCEL'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteService(service);
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.red,
                                                      ),
                                                      child:
                                                          const Text('DELETE'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              break;
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddAgriculturalServiceScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
