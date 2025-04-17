import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/providers/market_info_provider.dart';
import 'package:masoko_tips/models/market_info.dart';
import 'package:masoko_tips/screens/market_info/edit_market_info_screen.dart';
import 'package:masoko_tips/screens/market_info/market_info_detail_screen.dart';
import 'package:masoko_tips/widgets/custom_app_bar.dart';
import 'package:masoko_tips/widgets/custom_drawer.dart';
import 'package:masoko_tips/widgets/loading_indicator.dart';
import 'package:masoko_tips/widgets/error_message.dart';
import 'package:masoko_tips/widgets/empty_state.dart';
import 'package:masoko_tips/utils/date_utils.dart';
import 'package:masoko_tips/utils/theme.dart';

class MarketInfoListScreen extends StatefulWidget {
  const MarketInfoListScreen({super.key});

  @override
  State<MarketInfoListScreen> createState() => _MarketInfoListScreenState();
}

class _MarketInfoListScreenState extends State<MarketInfoListScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<MarketInfo> _marketInfoList = [];
  List<MarketInfo> _filteredMarketInfoList = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadMarketInfo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final marketInfoProvider =
          Provider.of<MarketInfoProvider>(context, listen: false);
      await marketInfoProvider.loadMarketInfo();
      setState(() {
        _marketInfoList = marketInfoProvider.marketInfoList;
        _filteredMarketInfoList = _marketInfoList;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredMarketInfoList = _marketInfoList.where((marketInfo) {
        final searchQuery = _searchController.text.toLowerCase();
        final locationQuery = _locationController.text.toLowerCase();
        final categoryQuery = _categoryController.text.toLowerCase();

        final matchesSearch =
            marketInfo.title.toLowerCase().contains(searchQuery) ||
                marketInfo.content.toLowerCase().contains(searchQuery);
        final matchesLocation = locationQuery.isEmpty ||
            (marketInfo.location?.toLowerCase() ?? '').contains(locationQuery);
        final matchesCategory = categoryQuery.isEmpty ||
            (marketInfo.category?.toLowerCase() ?? '').contains(categoryQuery);

        return matchesSearch && matchesLocation && matchesCategory;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _categoryController.clear();
      _filteredMarketInfoList = _marketInfoList;
      _showFilters = false;
    });
  }

  Future<void> _deleteMarketInfo(MarketInfo marketInfo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Market Info'),
        content: Text('Are you sure you want to delete "${marketInfo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        final marketInfoProvider =
            Provider.of<MarketInfoProvider>(context, listen: false);
        await marketInfoProvider.deleteMarketInfo(marketInfo.id);
        await _loadMarketInfo();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Market info deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error deleting market info: ${e.toString()}')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Information'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditMarketInfoScreen(),
                ),
              ).then((_) => _loadMarketInfo());
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          if (_showFilters)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _applyFilters(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _applyFilters(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _applyFilters(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _error != null
                    ? ErrorMessage(
                        error: _error!,
                        onRetry: _loadMarketInfo,
                      )
                    : _filteredMarketInfoList.isEmpty
                        ? EmptyState(
                            icon: Icons.info_outline,
                            message: 'No market information found',
                            actionText: 'Add New',
                            onAction: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditMarketInfoScreen(),
                                ),
                              ).then((_) => _loadMarketInfo());
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMarketInfo,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredMarketInfoList.length,
                              itemBuilder: (context, index) {
                                final marketInfo =
                                    _filteredMarketInfoList[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MarketInfoDetailScreen(
                                            marketInfo: marketInfo,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (marketInfo.imageUrl != null)
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            child: Image.network(
                                              marketInfo.imageUrl!,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 200,
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      marketInfo.title,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  if (marketInfo.isActive ||
                                                      marketInfo.isFeatured)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: marketInfo
                                                                .isActive
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors.grey
                                                                .withOpacity(
                                                                    0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        marketInfo.isActive
                                                            ? 'ACTIVE'
                                                            : 'FEATURED',
                                                        style: TextStyle(
                                                          color: marketInfo
                                                                  .isActive
                                                              ? Colors.green
                                                              : Colors.grey,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                marketInfo.content,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    marketInfo.location ?? '',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    Icons.category,
                                                    size: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    marketInfo.category ?? '',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditMarketInfoScreen(
                                                            marketInfo:
                                                                marketInfo,
                                                          ),
                                                        ),
                                                      ).then((_) =>
                                                          _loadMarketInfo());
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    color: Colors.red,
                                                    onPressed: () =>
                                                        _deleteMarketInfo(
                                                            marketInfo),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
