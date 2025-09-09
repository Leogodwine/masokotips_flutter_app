import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../widgets/app_scaffold.dart';
import '../../services/api_service.dart';
import '../../utils/logger.dart';
import '../../config/dev_config.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  ApiService? _apiService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _fetchOrders();
  }

  void _initializeApiService() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null) {
      _apiService = ApiService(
        baseUrl: '${DevConfig.ngrokUrl}/api',
        apiKey: 'your-api-key',
      );
      _apiService!.setAuthToken(authProvider.token!);
    }
  }

  Future<void> _fetchOrders() async {
    if (_apiService == null) {
      setState(() {
        _error = 'API service not available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      final isSeller = user?.roles.contains('seller') ?? false;

      Log.e('User is seller: $isSeller');

      Map<String, dynamic> response;
      if (isSeller) {
        Log.e('Fetching seller orders...');
        response = await _apiService!.getSellerOrders();
      } else {
        Log.e('Fetching buyer orders...');
        response = await _apiService!.getOrders();
      }

      Log.e('Orders response: $response');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> ordersData = response['data'];
        _orders = ordersData.map((json) => Order.fromApiJson(json)).toList();
        Log.e('Loaded ${_orders.length} orders');
      } else {
        _error = 'Failed to fetch orders';
        Log.e('Failed to fetch orders: $response');
      }
    } catch (e) {
      Log.e('Error fetching orders: $e');
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My Orders',
      showBackButton: true,
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
              'Error Loading Orders',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchOrders,
              child: const Text('RETRY'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Your order history will appear here once you make your first purchase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text('START SHOPPING'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: TZS ${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items: ${order.items.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(order.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Address: ${order.deliveryAddress}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cancel button for eligible orders (only for buyers)
                  if (!_isSeller() &&
                      (order.status == OrderStatus.pending ||
                          order.status == OrderStatus.processing))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showCancelDialog(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red[700],
                          elevation: 0,
                        ),
                        child: const Text('Cancel Order'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSeller() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    return user?.roles.contains('seller') ?? false;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCancelDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: Text(
              'Are you sure you want to cancel order #${order.id}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Order'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelOrder(order);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );
  }

  void _cancelOrder(Order order) async {
    final ordersProvider = context.read<OrdersProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await ordersProvider.cancelOrder(order.id);

    if (mounted) {
      if (ordersProvider.error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(ordersProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the orders list
        _fetchOrders();
      }
    }
  }
}
