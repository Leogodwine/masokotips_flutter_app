import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transport.dart';
import '../../providers/admin_provider.dart';
import 'transport_form_screen.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';
import 'package:lottie/lottie.dart';

class AdminTransportManagementScreen extends StatefulWidget {
  const AdminTransportManagementScreen({super.key});

  @override
  State<AdminTransportManagementScreen> createState() =>
      _AdminTransportManagementScreenState();
}

class _AdminTransportManagementScreenState
    extends State<AdminTransportManagementScreen> {
  bool _isLoading = false;
  bool _isPaginating = false;
  String? _error;
  List<Transport> _transports = [];
  String _searchQuery = '';
  String? _selectedStatus;
  String _sortBy = 'nameAsc'; // nameAsc, nameDesc, priceAsc, priceDesc, dateAsc
  final int _pageSize = 10;
  bool _hasMore = true;

  Future<void> _loadTransports({bool reset = true}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
      if (reset) {
        _transports = [];
        _hasMore = true;
      }
    });
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final newTransports =
          await adminProvider.loadTransports(offset: 0, limit: _pageSize);
      if (newTransports.isEmpty && reset) {
        setState(() {
          _hasMore = false;
        });
      }
      setState(() {
        _transports = newTransports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransports() async {
    if (_isPaginating || !_hasMore || _isLoading) return;
    setState(() => _isPaginating = true);
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final newTransports = await adminProvider.loadTransports(
          offset: _transports.length, limit: _pageSize);
      setState(() {
        _isPaginating = false;
        if (newTransports.isEmpty) {
          _hasMore = false;
        } else {
          _transports.addAll(newTransports);
        }
      });
    } catch (e) {
      setState(() => _isPaginating = false);
    }
  }

  void _applySort() {
    final sortedList = List<Transport>.from(_transports);

    switch (_sortBy) {
      case 'nameAsc':
        sortedList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'nameDesc':
        sortedList.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'priceAsc':
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'priceDesc':
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'dateAsc':
        sortedList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        break;
    }

    setState(() {
      _transports = sortedList;
    });
  }

  Widget buildFilterAndSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'nameAsc', child: Text('Name ↑')),
                  DropdownMenuItem(value: 'nameDesc', child: Text('Name ↓')),
                  DropdownMenuItem(value: 'priceAsc', child: Text('Price ↑')),
                  DropdownMenuItem(value: 'priceDesc', child: Text('Price ↓')),
                  DropdownMenuItem(value: 'dateAsc', child: Text('Date ↑')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _applySort();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _selectedStatus = null),
                child: const Text('All'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => setState(() => _selectedStatus = 'active'),
                child: const Text('Active'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => setState(() => _selectedStatus = 'inactive'),
                child: const Text('Inactive'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTransports();
  }

  Future<void> _deleteTransport(Transport transport) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transport'),
        content: Text('Are you sure you want to delete ${transport.title}?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await adminProvider.deleteTransport(transport.id!);
        _loadTransports();
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Transport deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error deleting transport: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildTransportCard(BuildContext context, Transport transport) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransportFormScreen(transport: transport),
              ),
            ).then((_) => _loadTransports());
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: transport.imageUrl != null &&
                              transport.imageUrl!.isNotEmpty
                          ? CachedNetworkImageWithCors(
                              imageUrl: transport.imageUrl!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) {
                                return Container(
                                  height: 140,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.error_outline),
                                );
                              },
                            )
                          : Container(
                              height: 140,
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: const Icon(Icons.directions_car,
                                  size: 50, color: Colors.grey),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Chip(
                        label: Text(
                          transport.status.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: transport.status == 'active'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  transport.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        transport.vehicleLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.directions_car,
                        size: 14, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        transport.vehicleType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.scale, size: 14, color: theme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      '${transport.capacity} tons',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const Spacer(),
                    IconButton(
                      iconSize: 18,
                      icon: const Icon(Icons.delete),
                      color: Colors.redAccent,
                      onPressed: () => _deleteTransport(transport),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTransports = _transports.where((t) {
      final matchesSearch = t.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          t.vehicleLocation.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == null ||
          t.status.toLowerCase() == _selectedStatus!.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Management'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh list',
            onPressed: _loadTransports,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransportFormScreen(),
            ),
          ).then((_) => _loadTransports());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transport'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransports,
        child: _isLoading
            ? Center(
                child: Lottie.asset(
                  'assets/animations/loading.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/error.json',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_error',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadTransports,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : _transports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/empty.json',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transports available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TransportFormScreen(),
                                  ),
                                ).then((_) => _loadTransports());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Transport'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            buildFilterAndSearch(context),
                            MediaQuery.of(context).size.width > 600
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.4,
                                    ),
                                    itemCount: filteredTransports.length,
                                    itemBuilder: (context, index) {
                                      final transport =
                                          filteredTransports[index];
                                      return _buildTransportCard(
                                          context, transport);
                                    },
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredTransports.length,
                                    itemBuilder: (context, index) {
                                      final transport =
                                          filteredTransports[index];
                                      return _buildTransportCard(
                                          context, transport);
                                    },
                                  ),
                            if (_hasMore)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: _isPaginating
                                      ? const CircularProgressIndicator()
                                      : TextButton(
                                          onPressed: _loadMoreTransports,
                                          child: const Text('Load More'),
                                        ),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
      ),
    );
  }
}
