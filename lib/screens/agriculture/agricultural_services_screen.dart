import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/agriculture_service.dart';
import '../../models/service.dart';
import '../services/service_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../screens/provider/service_provider_manager.dart';

class AgriculturalServicesScreen extends StatefulWidget {
  const AgriculturalServicesScreen({super.key});

  @override
  State<AgriculturalServicesScreen> createState() =>
      _AgriculturalServicesScreenState();
}

class _AgriculturalServicesScreenState
    extends State<AgriculturalServicesScreen> {
  final AgricultureService _agricultureService = AgricultureService();
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  bool _hasMore = true;
  int _page = 1;
  List<Service> _services = [];
  static const int _perPage = 10;
  String? _searchQuery;
  String? _sortBy;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  // Filter state
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minRating = 0;
  bool _hasActiveFilters = false;

  // Sort options
  static const Map<String, String> _sortOptions = {
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'rating_desc': 'Highest Rated',
    'newest': 'Newest First',
    'name_asc': 'Name: A to Z',
  };

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeServices() async {
    // Set auth token if available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      _agricultureService.setAuthToken(authProvider.token!);
    }

    await _loadInitialServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialServices() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });

    await _loadMoreServices();

    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadMoreServices() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // Load services from the agriculture service
      final services = await _agricultureService.getAgriculturalServices();

      setState(() {
        // If this is the first page, replace the services
        if (_page == 1) {
          _services = services;
        } else {
          // Otherwise, append the new services
          _services.addAll(services);
        }

        _isLoadingMore = false;
        _error = null;

        // If we got fewer services than the page size, we've reached the end
        if (services.length < _perPage) {
          _hasMore = false;
        } else {
          // Increment the page for next time
          _page++;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _error = 'Failed to load services. Please try again later.';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading services: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'RETRY',
              onPressed: () => _loadMoreServices(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadServices() async {
    if (mounted) {
      setState(() {
        _isInitialLoading = true;
        _error = null;
      });
    }

    try {
      final services = await _agricultureService.getAgriculturalServices();

      if (mounted) {
        setState(() {
          // Apply search filter if there's a search query
          if (_searchQuery != null && _searchQuery!.isNotEmpty) {
            _services = services.where((service) {
              return service.title
                      .toLowerCase()
                      .contains(_searchQuery!.toLowerCase()) ||
                  service.description
                      .toLowerCase()
                      .contains(_searchQuery!.toLowerCase()) ||
                  (service.subcategory != null &&
                      service.subcategory!
                          .toLowerCase()
                          .contains(_searchQuery!.toLowerCase()));
            }).toList();
          } else {
            _services = services;
          }

          // Apply sorting if _sortBy is set
          if (_sortBy != null) {
            switch (_sortBy) {
              case 'price_asc':
                _services.sort((a, b) => a.price.compareTo(b.price));
                break;
              case 'price_desc':
                _services.sort((a, b) => b.price.compareTo(a.price));
                break;
              case 'name_asc':
                _services.sort((a, b) => a.title.compareTo(b.title));
                break;
              case 'newest':
                _services.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                break;
              // Add other sort options as needed
            }
          }

          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _handleSort(String? sortBy) async {
    setState(() {
      _sortBy = sortBy;
      _services.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadServices();
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _priceRange = const RangeValues(0, 1000);
                          _minRating = 0;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      labels: RangeLabels(
                        '\$${_priceRange.start.round()}',
                        '\$${_priceRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() => _priceRange = values);
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Minimum Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => _minRating = value);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'priceRange': _priceRange,
                      'minRating': _minRating,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _priceRange = result['priceRange'];
        _minRating = result['minRating'];
        _hasActiveFilters =
            _minRating > 0 || _priceRange.start > 0 || _priceRange.end < 1000;
        _services.clear();
        _page = 1;
        _hasMore = true;
      });
      await _loadServices();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadServices();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No agricultural services available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'There are no agricultural services available yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ServiceProviderManager.openAddAgriculturalServiceScreen(
                context,
                (service) {
                  setState(() {
                    _services.add(service);
                  });
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add a Service'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Failed to load services',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInitialServices,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete ${service.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ServiceProviderManager.deleteService(context, service);
              setState(() {
                _services.removeWhere((s) => s.id == service.id);
              });
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

  @override
  Widget build(BuildContext context) {
    final isServiceProvider = ServiceProviderManager.isServiceProvider(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Services'),
        actions: [
          // Filter button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          ),
          // Sort button
          PopupMenuButton<String?>(
            icon: const Icon(Icons.sort),
            onSelected: _handleSort,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Default'),
              ),
              ..._sortOptions.entries.map(
                (entry) => PopupMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              ),
            ],
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ServiceSearchDelegate(_services, (query) {
                  setState(() {
                    _searchQuery = query;
                    _loadServices();
                  });
                }),
              );
            },
          ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _services.clear();
                      _page = 1;
                      _hasMore = true;
                    });
                    await _loadInitialServices();
                  },
                  child: _services.isEmpty && !_isLoadingMore
                      ? _buildEmptyState()
                      : AnimationLimiter(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _services.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _services.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final service = _services[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(12),
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: service.imageUrl ??
                                                'https://via.placeholder.com/60',
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.error,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          service.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              service.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amber[700],
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  '4.5',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '(10 reviews)',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '\$${service.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            if (isServiceProvider) ...[
                                              const SizedBox(width: 8),
                                              PopupMenuButton<String>(
                                                icon:
                                                    const Icon(Icons.more_vert),
                                                onSelected: (value) {
                                                  switch (value) {
                                                    case 'edit':
                                                      ServiceProviderManager
                                                          .openEditServiceScreen(
                                                        context,
                                                        service,
                                                        (updatedService) {
                                                          setState(() {
                                                            final index = _services
                                                                .indexWhere((s) =>
                                                                    s.id ==
                                                                    updatedService
                                                                        .id);
                                                            if (index != -1) {
                                                              _services[index] =
                                                                  updatedService;
                                                            }
                                                          });
                                                        },
                                                      );
                                                      break;
                                                    case 'delete':
                                                      _showDeleteConfirmationDialog(
                                                          service);
                                                      break;
                                                  }
                                                },
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
                                              ),
                                            ],
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ServiceDetailScreen(
                                                service: service,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
      floatingActionButton: isServiceProvider
          ? FloatingActionButton(
              onPressed: () {
                ServiceProviderManager.openAddAgriculturalServiceScreen(
                  context,
                  (service) {
                    setState(() {
                      _services.add(service);
                    });
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class ServiceSearchDelegate extends SearchDelegate {
  final List<Service> services;
  final Function(String) onSearch;

  ServiceSearchDelegate(this.services, this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a search term'),
      );
    }

    final filteredServices = services.where((service) {
      return service.title.toLowerCase().contains(query.toLowerCase()) ||
          service.description.toLowerCase().contains(query.toLowerCase()) ||
          (service.subcategory != null &&
              service.subcategory!.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    if (filteredServices.isEmpty) {
      return const Center(
        child: Text('No services found'),
      );
    }

    return ListView.builder(
      itemCount: filteredServices.length,
      itemBuilder: (context, index) {
        final service = filteredServices[index];
        return ListTile(
          title: Text(service.title),
          subtitle: Text(service.description),
          onTap: () {
            onSearch(query);
            close(context, null);
          },
        );
      },
    );
  }
}
