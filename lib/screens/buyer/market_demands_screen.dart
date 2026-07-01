import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/buying_request.dart';
import '../../services/api_service.dart';
import '../../utils/image_upload_helper.dart';
import '../../utils/logger.dart';
import '../../widgets/friendly_error_display.dart';
import 'market_demand_detail_screen.dart';

class MarketDemandsScreen extends StatefulWidget {
  const MarketDemandsScreen({super.key});

  @override
  State<MarketDemandsScreen> createState() => _MarketDemandsScreenState();
}

class _MarketDemandsScreenState extends State<MarketDemandsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<BuyingRequest> _demands = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  int _currentPage = 1;
  int _lastPage = 1;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchDemands(refresh: true);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _currentPage < _lastPage) {
        _fetchDemands(refresh: false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchDemands(refresh: true);
    });
  }

  Future<void> _fetchDemands({required bool refresh}) async {
    if (!mounted) return;
    
    setState(() {
      if (refresh) {
        _isLoading = true;
        _currentPage = 1;
        _demands.clear();
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final queryParam = _searchController.text.trim();
      final url = 'market-demands?page=$_currentPage&per_page=15${queryParam.isNotEmpty ? '&search=${Uri.encodeComponent(queryParam)}' : ''}';

      final response = await apiService.getPublicRequest(url);

      if (!mounted) return;

      if (response.containsKey('data') && response['data'] is List) {
        final List<dynamic> list = response['data'];
        final List<BuyingRequest> fetched = list.map((j) => BuyingRequest.fromJson(j)).toList();
        
        final meta = response['meta'] ?? {};
        _lastPage = meta['last_page'] ?? 1;

        setState(() {
          if (refresh) {
            _demands = fetched;
          } else {
            _demands.addAll(fetched);
          }
          _currentPage++;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _error = 'Failed to load demands.';
        });
      }
    } catch (e) {
      Log.e('MarketDemandsScreen: Error fetching demands: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _error = 'Error loading demands. Please check connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market Demands',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search demands (e.g. vanilla, location)...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A8C4E)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchDemands(refresh: true);
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchDemands(refresh: true),
              color: const Color(0xFF1A8C4E),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _demands.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FriendlyErrorDisplay(
            error: _error,
            onRetry: () => _fetchDemands(refresh: true),
          ),
        ),
      );
    }

    if (_demands.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              children: [
                Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No active demands found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try refining your search keyword',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _demands.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _demands.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final demand = _demands[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: _buildDemandListItem(demand),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDemandListItem(BuyingRequest demand) {
    final theme = Theme.of(context);
    final buyerName = demand.user?['name'] ?? 'Anonymous Buyer';
    final buyerAvatar = demand.user?['avatar'];
    final hasImage = demand.imageUrl != null && demand.imageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
        border: Border.all(
          color: const Color(0xFF1A8C4E).withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MarketDemandDetailScreen(demand: demand),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image/Placeholder on left
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: hasImage
                        ? Image.network(
                            ImageUploadHelper.constructFullImageUrl(demand.imageUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content on right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge + Quantity
                      Row(
                        children: [
                          _badge('WANTED', const Color(0xFF1A8C4E)),
                          const Spacer(),
                          Text(
                            '${demand.quantity} ${demand.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Title
                      Text(
                        demand.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Location & Time ago
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              demand.deliveryLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ),
                          Text(
                            _timeAgo(demand.createdAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Divider & Buyer
                      Container(
                        height: 0.5,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: const Color(0xFF1A8C4E).withValues(alpha: 0.12),
                            backgroundImage: buyerAvatar != null
                                ? NetworkImage(ImageUploadHelper.constructFullImageUrl(buyerAvatar))
                                : null,
                            child: buyerAvatar == null
                                ? Text(
                                    buyerName.isNotEmpty ? buyerName[0].toUpperCase() : 'B',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1A8C4E)),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              buyerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (demand.expiresAt != null) ...[
                            _expiryWidget(demand.expiresAt!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A8C4E), Color(0xFF2ECC71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.shopping_basket_outlined, size: 36, color: Colors.white60),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _expiryWidget(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    final remaining = diff.isNegative ? Duration.zero : diff;
    
    if (remaining == Duration.zero) {
      return Text('Expired', style: TextStyle(fontSize: 10, color: Colors.grey[500]));
    }
    
    final Color color;
    if (remaining.inHours < 6) {
      color = Colors.red;
    } else if (remaining.inHours < 24) {
      color = Colors.orange;
    } else {
      color = const Color(0xFF1A8C4E);
    }

    final String label;
    final d = remaining.inDays;
    if (d > 0) {
      label = '${d}d left';
    } else {
      label = '${remaining.inHours}h left';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time_outlined, size: 10, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
