import 'package:flutter/material.dart';
import '../../models/service.dart';
import 'service_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/reviews_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/service_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';

class ServiceListScreen extends StatefulWidget {
  final String category;

  const ServiceListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final List<Service> _services = [];
  static const int _perPage = 10;
  String? _searchQuery;
  String? _sortBy;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService(
    baseUrl: ApiConfig.baseUrl,
    apiKey: 'your-api-key', // Replace with actual API key
  );
  final ServiceService _serviceService = ServiceService();
  String? _error;

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
      _serviceService.setAuthToken(authProvider.token!);
    }

    // Check if API is available
    final isApiAvailable = await _apiService.checkConnection();
    if (!isApiAvailable) {
      setState(() {
        _error = 'API server is not available. Using local data instead.';
      });
    }

    await _loadInitialServices();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
      // Try to load from API first
      final result = await _apiService.getServices(
        category: widget.category,
        search: _searchQuery,
        sortBy: _sortBy,
        page: _page,
        perPage: _perPage,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        minRating: _minRating,
      );

      List<Service> services = result['services'];
      int currentPage = result['currentPage'];
      int lastPage = result['lastPage'];

      setState(() {
        _services.addAll(services);
        _page++;
        _hasMore = currentPage < lastPage;
        _isLoadingMore = false;
        _error = null;
      });
    } catch (e) {
      // If API fails, try to load from local service service
      try {
        final services = await _serviceService.getMyServices();

        // Filter services by category if needed
        final filteredServices = services
            .where(
                (service) => service.categoryId.toString() == widget.category)
            .toList();

        setState(() {
          _services.addAll(filteredServices);
          _isLoadingMore = false;
          _error = null;
        });
      } catch (localError) {
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
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _services.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadMoreServices();
  }

  Future<void> _handleSort(String? sortBy) async {
    setState(() {
      _sortBy = sortBy;
      _services.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadMoreServices();
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
      await _loadMoreServices();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreServices();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.handyman_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No services available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'There are no services in this category yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/provider/add-service');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
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
                delegate: ServiceSearchDelegate(
                  onSearch: _performSearch,
                  searchController: _searchController,
                ),
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
                  child: Consumer<ReviewsProvider>(
                    builder: (context, reviewsProvider, child) {
                      if (_services.isEmpty && !_isLoadingMore) {
                        return _buildEmptyState();
                      }

                      return AnimationLimiter(
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
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
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
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
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
                                      trailing: Text(
                                        '\$${service.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                        ),
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
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/provider/add-service');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ServiceSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;
  final TextEditingController searchController;
  static const String _searchHistoryKey = 'service_search_history';
  static const int _maxHistoryItems = 10;
  List<String> _searchHistory = [];

  ServiceSearchDelegate({
    required this.onSearch,
    required this.searchController,
  }) {
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_searchHistoryKey, _searchHistory);
  }

  Future<void> addToHistory(String query) async {
    if (query.isEmpty) return;

    _searchHistory.remove(query); // Remove if exists
    _searchHistory.insert(0, query); // Add to beginning

    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory.removeLast(); // Remove oldest item
    }

    await _saveSearchHistory();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchController.clear();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildSearchHistory();
    }
    onSearch(query);
    return Container(); // Results will be shown in the main screen
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildSearchHistory();
    }

    // Filter history based on query
    final suggestions = _searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            searchController.text = suggestion;
            onSearch(suggestion);
            addToHistory(suggestion);
          },
        );
      },
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return const Center(
        child: Text('No recent searches'),
      );
    }

    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final item = _searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      setState(() {
                        _searchHistory.removeAt(index);
                      });
                      await _saveSearchHistory();
                    },
                  ),
                  onTap: () {
                    query = item;
                    searchController.text = item;
                    onSearch(item);
                    addToHistory(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
