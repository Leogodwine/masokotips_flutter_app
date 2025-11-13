import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/service_service.dart';
import '../../models/service.dart';
import '../../models/category.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({Key? key}) : super(key: key);

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  List<Service> _services = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  ServiceService? _serviceService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _loadServices();
    _loadCategories();
  }

  void _initializeApiService() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null) {
      _serviceService = ServiceService();
      _serviceService!.setAuthToken(authProvider.token!);
    }
  }

  Future<void> _loadServices() async {
    if (_serviceService == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Loading provider services...');

      // Check if user has service_provider role using ServiceService
      if (_serviceService != null) {
        try {
          final response = await _serviceService!.getRequest('user/roles');
          final roles = response['roles'] as List<dynamic>? ?? [];
          final hasServiceProviderRole =
              roles.any((role) => role['name'] == 'service_provider');

          if (!hasServiceProviderRole) {
            setState(() {
              _errorMessage =
                  'You need to have Service Provider role to manage services.';
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          debugPrint('Error checking user roles: $e');
          // Continue without role check if it fails
        }
      }

      // Load services using the service provider API
      final servicesResponse =
          await _serviceService!.getRequest('service-provider/services');
      if (servicesResponse['success'] == true) {
        final List<dynamic> servicesJson = servicesResponse['services'] ?? [];
        setState(() {
          _services =
              servicesJson.map((json) => Service.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() {
        _errorMessage = 'Failed to load services: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    if (_serviceService == null) return;

    try {
      final categories =
          await _serviceService!.getAgriculturalServiceCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _deleteService(Service service) async {
    if (_serviceService == null) return;

    // Capture context-dependent objects before async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _serviceService!
          .deleteRequest('service-provider/services/${service.id}');
      setState(() {
        _services.removeWhere((s) => s.id == service.id);
      });
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting service: $e');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete service: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteService(service);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Agricultural Services'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadServices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _services.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.handyman_outlined,
                                size: 60,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Services Yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Start offering agricultural services to farmers and grow your business',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddServiceScreen(
                                      onServiceAdded: (service) {
                                        setState(() {
                                          _services.add(service);
                                        });
                                      },
                                      serviceService: _serviceService!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Your First Service'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadServices,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Card(
                              elevation: 8,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // Navigate to service details if needed
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header with image and actions
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Service Image
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: service.imageUrl != null &&
                                                      service
                                                          .imageUrl!.isNotEmpty
                                                  ? Image.network(
                                                      service.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.3),
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons.handyman,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            size: 32,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Theme.of(context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            Theme.of(context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: 0.3),
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.handyman,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: 32,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Service Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  service.title ?? 'No Title',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  service.description ??
                                                      'No Description',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    height: 1.4,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Action Menu
                                          PopupMenuButton<String>(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.grey[600],
                                            ),
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    SizedBox(width: 12),
                                                    Text('Edit Service'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        color: Colors.red),
                                                    SizedBox(width: 12),
                                                    Text('Delete Service',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditServiceScreen(
                                                      service: service,
                                                      onServiceUpdated:
                                                          (updatedService) {
                                                        setState(() {
                                                          final index = _services
                                                              .indexWhere((s) =>
                                                                  s.id ==
                                                                  service.id);
                                                          if (index != -1) {
                                                            _services[index] =
                                                                updatedService;
                                                          }
                                                        });
                                                      },
                                                      serviceService:
                                                          _serviceService!,
                                                    ),
                                                  ),
                                                );
                                              } else if (value == 'delete') {
                                                _showDeleteDialog(service);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Price and Status Section
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Price
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.attach_money,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'TZS ${service.price.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Status Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: service.isActive == true
                                                  ? Colors.green
                                                      .withValues(alpha: 0.1)
                                                  : Colors.orange
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: service.isActive == true
                                                    ? Colors.green
                                                        .withValues(alpha: 0.3)
                                                    : Colors.orange
                                                        .withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  service.isActive == true
                                                      ? Icons.check_circle
                                                      : Icons.pending,
                                                  color:
                                                      service.isActive == true
                                                          ? Colors.green
                                                          : Colors.orange,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  service.isActive == true
                                                      ? 'Active'
                                                      : 'Pending',
                                                  style: TextStyle(
                                                    color:
                                                        service.isActive == true
                                                            ? Colors.green
                                                            : Colors.orange,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Additional Info (if available)
                                      if (service.subcategory != null ||
                                          service.location != null) ...[
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            if (service.subcategory != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.category,
                                                      size: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      service.subcategory!,
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (service.location != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      service.location!,
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddServiceScreen(
                  onServiceAdded: (service) {
                    setState(() {
                      _services.insert(0, service);
                    });
                  },
                  serviceService: _serviceService!,
                  category: _categories.isNotEmpty ? _categories.first : null,
                ),
              ),
            );
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Add Service',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
