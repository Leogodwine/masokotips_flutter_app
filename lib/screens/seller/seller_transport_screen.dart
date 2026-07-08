import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/transport.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/logger.dart';
import 'add_transport_screen.dart';
import 'edit_transport_screen.dart';
import '../../utils/extensions.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class SellerTransportScreen extends StatefulWidget {
  const SellerTransportScreen({Key? key}) : super(key: key);

  @override
  State<SellerTransportScreen> createState() => _SellerTransportScreenState();
}

class _SellerTransportScreenState extends State<SellerTransportScreen> {
  List<Transport> _transports = [];
  bool _isLoading = false;
  String? _error;
  ApiService? _apiService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _loadTransports();
  }

  void _initializeApiService() {
    final authProvider = context.read<AuthProvider>();
    Log.e('Auth token in seller transport screen: ${authProvider.token}');
    if (authProvider.token != null) {
      _apiService = ApiService(
        baseUrl: ApiConfig.baseUrl,
        apiKey: authProvider.token!,
      );
      Log.e(
          'ApiService initialized with token: ${authProvider.token!.substring(0, 10)}...');
    } else {
      Log.e('No auth token available in seller transport screen');
    }
  }

  Future<void> _loadTransports() async {
    if (_apiService == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Log.e('Loading seller transports...');
      final response = await _apiService!.getSellerTransports();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> transportsData = response['data'];
        Log.e('Raw transports data: $transportsData');
        Log.e('Number of transports in response: ${transportsData.length}');

        _transports = transportsData.map((json) {
          try {
            return Transport.fromJson(json);
          } catch (e) {
            Log.e('Error parsing transport JSON: $e');
            Log.e('Problematic JSON: $json');
            rethrow;
          }
        }).toList();
        Log.e('Loaded ${_transports.length} seller transports');
        Log.e(
            'Transport details: ${_transports.map((t) => '${t.title} (${t.id})').join(', ')}');
      } else {
        _error = 'Failed to load transports';
        Log.e('Failed to load seller transports: $response');
      }
    } catch (e) {
      Log.e('Error loading seller transports: $e');
      final errorStr = e.toFriendlyError;
      if (errorStr.contains('subscription_required') ||
          errorStr.contains('SUBSCRIPTION_EXPIRED')) {
        _error = 'Your Transporter subscription has expired or is inactive.';
      } else {
        _error = errorStr;
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTransport(Transport transport) async {
    if (_apiService == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await _apiService!.deleteTransport(transport.id!);
      setState(() {
        _transports.removeWhere((t) => t.id == transport.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${transport.title} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myTransportServices),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransports,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransportScreen(
                onTransportAdded: (transport) {
                  setState(() {
                    _transports.insert(0, transport);
                  });
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addTransport),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Transports',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTransports,
              child: Text(AppLocalizations.of(context)!.retryAlt),
            ),
          ],
        ),
      );
    }

    if (_transports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Transport Services Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Add your transport services to start offering delivery and transportation to customers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransportScreen(
                      onTransportAdded: (transport) {
                        setState(() {
                          _transports.insert(0, transport);
                        });
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.addYourFirstTransport),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transports.length,
        itemBuilder: (context, index) {
          final transport = _transports[index];
          return _buildTransportCard(transport);
        },
      ),
    );
  }

  Widget _buildTransportCard(Transport transport) {
    final isAvailable = transport.status.toLowerCase() == 'available';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Transport Image with Status
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: (transport.processedImageUrl.isNotEmpty)
                      ? transport.processedImageUrl
                      : 'https://via.placeholder.com/600x300?text=No+Image',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey[200]!, Colors.grey[400]!],
                      ),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car,
                            size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No Image Available',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              // Status Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAvailable ? Icons.check_circle : Icons.access_time,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transport.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Title Overlay
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  transport.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Type and Location
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              transport.vehicleType,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              transport.vehicleLocation,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Capacity and Price
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.scale,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${transport.capacity} kg capacity',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TZS ${transport.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Category and Description
                if (transport.category != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transport.category!.name,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  transport.description ?? 'No description available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTransportScreen(
                                transport: transport,
                                onTransportUpdated: (updatedTransport) {
                                  setState(() {
                                    final index = _transports.indexWhere(
                                        (t) => t.id == updatedTransport.id);
                                    if (index != -1) {
                                      _transports[index] = updatedTransport;
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(AppLocalizations.of(context)!.edit),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteDialog(transport),
                        icon: const Icon(Icons.delete, size: 18),
                        label: Text(AppLocalizations.of(context)!.delete),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
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
  }

  void _showDeleteDialog(Transport transport) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteTransportService),
          content: Text(
              'Are you sure you want to delete "${transport.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTransport(transport);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }
}
