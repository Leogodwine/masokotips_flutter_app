import 'package:flutter/material.dart';
import '../models/market_info.dart';
import '../services/market_info_service.dart';
import '../widgets/error_handler.dart';

class MarketInfoScreen extends StatefulWidget {
  const MarketInfoScreen({super.key});

  @override
  State<MarketInfoScreen> createState() => _MarketInfoScreenState();
}

class _MarketInfoScreenState extends State<MarketInfoScreen> {
  final MarketInfoService _marketInfoService = MarketInfoService();
  List<MarketInfo> _marketInfoList = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadMarketInfo();
  }

  Future<void> _loadMarketInfo() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final marketInfo = await _marketInfoService.getAllMarketInfo();
      if (mounted) {
        setState(() {
          _marketInfoList = marketInfo;
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

  List<String> _getUniqueCategories() {
    final categories = _marketInfoList
        .where((info) => info.category != null)
        .map((info) => info.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  List<String> _getUniqueLocations() {
    final locations = _marketInfoList
        .where((info) => info.location != null)
        .map((info) => info.location!)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  }

  List<MarketInfo> _getFilteredMarketInfo() {
    return _marketInfoList.where((info) {
      final matchesCategory =
          _selectedCategory == null || info.category == _selectedCategory;
      final matchesLocation =
          _selectedLocation == null || info.location == _selectedLocation;
      return matchesCategory && matchesLocation;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMarketInfo = _getFilteredMarketInfo();
    final categories = _getUniqueCategories();
    final locations = _getUniqueLocations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Information'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorHandler(
                  message: _error!,
                  onRetry: _loadMarketInfo,
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Category',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Categories'),
                                ),
                                ...categories.map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLocation,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Location',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Locations'),
                                ),
                                ...locations.map(
                                  (location) => DropdownMenuItem(
                                    value: location,
                                    child: Text(location),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedLocation = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredMarketInfo.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No market information available',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your filters',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredMarketInfo.length,
                              itemBuilder: (context, index) {
                                final marketInfo = filteredMarketInfo[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (marketInfo.imageUrl != null)
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                          child: Image.network(
                                            marketInfo.imageUrl!,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Error loading image: $error');
                                              return Container(
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.error_outline,
                                                    size: 48,
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
                                            Text(
                                              marketInfo.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              marketInfo.content,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(height: 16),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                if (marketInfo.location != null)
                                                  Chip(
                                                    label: Text(
                                                      marketInfo.location!,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    backgroundColor:
                                                        Colors.blue[100],
                                                    labelStyle: TextStyle(
                                                      color: Colors.blue[800],
                                                    ),
                                                  ),
                                                if (marketInfo.category != null)
                                                  Chip(
                                                    label: Text(
                                                      marketInfo.category!,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    backgroundColor:
                                                        Colors.green[100],
                                                    labelStyle: TextStyle(
                                                      color: Colors.green[800],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
