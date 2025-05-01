import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/market_info_provider.dart';
import '../../models/market_info.dart';
import 'edit_market_info_screen.dart';
import 'market_info_detail_screen.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../widgets/empty_state.dart';

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
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters([String? _]) {
    setState(() {
      final search = _searchController.text.toLowerCase();
      final location = _locationController.text.toLowerCase();
      final category = _categoryController.text.toLowerCase();

      _filteredMarketInfoList = _marketInfoList.where((marketInfo) {
        final matchesSearch = marketInfo.title.toLowerCase().contains(search) ||
            marketInfo.content.toLowerCase().contains(search);
        final matchesLocation = location.isEmpty ||
            marketInfo.location.toLowerCase().contains(location);
        final matchesCategory = category.isEmpty ||
            marketInfo.category.toLowerCase().contains(category);

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
        await marketInfoProvider.deleteMarketInfo(marketInfo.id.toString());
        await _loadMarketInfo();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Market info deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
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
        title: const Text('Market News'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditMarketInfoScreen()),
              ).then((_) => _loadMarketInfo());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilters(),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _error != null
                    ? ErrorMessage(error: _error!, onRetry: _loadMarketInfo)
                    : _filteredMarketInfoList.isEmpty
                        ? EmptyState(
                            icon: Icons.info_outline,
                            message: 'No market information found.',
                            actionText: 'Add New',
                            onAction: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const EditMarketInfoScreen()),
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
                                return _buildMarketInfoCard(marketInfo);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
                _searchController, 'Search', Icons.search, _applyFilters),
            const SizedBox(height: 16),
            _buildTextField(_locationController, 'Location', Icons.location_on,
                _applyFilters),
            const SizedBox(height: 16),
            _buildTextField(
                _categoryController, 'Category', Icons.category, _applyFilters),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, void Function(String)? onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildMarketInfoCard(MarketInfo marketInfo) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MarketInfoDetailScreen(marketInfo: marketInfo)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                marketInfo.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child:
                      const Center(child: Icon(Icons.broken_image, size: 48)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    marketInfo.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    marketInfo.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        marketInfo.location,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      Icon(Icons.category, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        marketInfo.category,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EditMarketInfoScreen(
                                    marketInfo: marketInfo)),
                          ).then((_) => _loadMarketInfo());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => _deleteMarketInfo(marketInfo),
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
  }
}
