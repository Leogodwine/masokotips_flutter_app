import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../models/product.dart';
import '../../models/market_info.dart';
import '../products/product_details_screen.dart';
import '../../providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../cart/cart_screen.dart';
import '../organic/edit_organic_product_screen.dart';
import '../services/service_detail_screen.dart';
import '../transport/transport_details_screen.dart';
import '../market_info/market_info_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedType = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final searchProvider = context.read<SearchProvider>();
      await searchProvider.search(query);

      setState(() {
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final searchProvider = context.read<SearchProvider>();
    searchProvider.clear();
    setState(() {
      _selectedType = 'all';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products, services, transports...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          final result = searchProvider.searchResult;

          if (_isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result == null) {
            return _buildEmptyState();
          }

          if (result.isEmpty) {
            return _buildNoResultsState();
          }

          return _buildSearchResults(result);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Search for products, services, transports and more',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found for "${_searchController.text}"',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeFilter(result),
          const SizedBox(height: 16),
          if (_selectedType == 'all' || _selectedType == 'products') ...[
            if (result.products.isNotEmpty) ...[
              _buildSectionTitle('Products', result.products.length),
              _buildProductList(result.products),
              const SizedBox(height: 16),
            ],
          ],
          if (_selectedType == 'all' || _selectedType == 'organic_products') ...[
            if (result.organicProducts.isNotEmpty) ...[
              _buildSectionTitle('Organic Products', result.organicProducts.length),
              _buildOrganicProductList(result.organicProducts),
              const SizedBox(height: 16),
            ],
          ],
          if (_selectedType == 'all' || _selectedType == 'services') ...[
            if (result.services.isNotEmpty) ...[
              _buildSectionTitle('Services', result.services.length),
              _buildServiceList(result.services),
              const SizedBox(height: 16),
            ],
          ],
          if (_selectedType == 'all' || _selectedType == 'transports') ...[
            if (result.transports.isNotEmpty) ...[
              _buildSectionTitle('Transports', result.transports.length),
              _buildTransportList(result.transports),
              const SizedBox(height: 16),
            ],
          ],
          if (_selectedType == 'all' || _selectedType == 'market_info') ...[
            if (result.marketInfo.isNotEmpty) ...[
              _buildSectionTitle('Market News', result.marketInfo.length),
              _buildMarketInfoList(result.marketInfo),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTypeFilter(SearchResult result) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTypeChip('All', 'all', result.totalCount),
          if (result.products.isNotEmpty)
            _buildTypeChip('Products', 'products', result.products.length),
          if (result.organicProducts.isNotEmpty)
            _buildTypeChip('Organic', 'organic_products', result.organicProducts.length),
          if (result.services.isNotEmpty)
            _buildTypeChip('Services', 'services', result.services.length),
          if (result.transports.isNotEmpty)
            _buildTypeChip('Transports', 'transports', result.transports.length),
          if (result.marketInfo.isNotEmpty)
            _buildTypeChip('News', 'market_info', result.marketInfo.length),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String type, int count) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : 'all';
          });
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$title ($count)',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TZS ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, _) {
                          return GestureDetector(
                            onTap: () {
                              cartProvider.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 16),
                            ),
                          );
                        },
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

  Widget _buildOrganicProductList(List<dynamic> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditOrganicProductScreen(product: product),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceList(List<dynamic> services) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.agriculture, color: Colors.white),
            ),
            title: Text(service.title),
            subtitle: Text(
              'TZS ${service.price?.toStringAsFixed(2) ?? "N/A"}',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(service: service),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTransportList(List<dynamic> transports) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transports.length,
      itemBuilder: (context, index) {
        final transport = transports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.local_shipping, color: Colors.white),
            ),
            title: Text(transport.title),
            subtitle: Text(transport.vehicleLocation),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransportDetailsScreen(transport: transport),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMarketInfoList(List<MarketInfo> marketInfoList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: marketInfoList.length,
      itemBuilder: (context, index) {
        final info = marketInfoList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.trending_up, color: Colors.white),
            ),
            title: Text(info.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarketInfoDetailScreen(marketInfo: info),
                ),
              );
            },
          ),
        );
      },
    );
  }
}