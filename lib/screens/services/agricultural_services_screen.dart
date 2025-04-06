import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/agriculture_service.dart';
import '../../models/service.dart';
import '../../widgets/error_handler.dart';

class AgriculturalServicesScreen extends StatefulWidget {
  const AgriculturalServicesScreen({super.key});

  @override
  State<AgriculturalServicesScreen> createState() =>
      _AgriculturalServicesScreenState();
}

class _AgriculturalServicesScreenState
    extends State<AgriculturalServicesScreen> {
  final AgricultureService _agricultureService = AgricultureService();
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null) {
      _agricultureService.setAuthToken(authProvider.token!);
      _loadServices();
    }
  }

  Future<void> _loadServices() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final services = await _agricultureService.getAgriculturalServices();
      if (mounted) {
        setState(() {
          _services = services;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agricultural Services'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorHandler(
                  message: _error!,
                  onRetry: _loadServices,
                )
              : RefreshIndicator(
                  onRefresh: _loadServices,
                  child: _services.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.agriculture_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No agricultural services available',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: service.imageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          service.imageUrl!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.agriculture,
                                          color: Colors.grey,
                                        ),
                                      ),
                                title: Text(service.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (service.subcategory != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Chip(
                                          label: Text(
                                            service.subcategory!,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          backgroundColor: Colors.green[100],
                                          labelStyle: TextStyle(
                                            color: Colors.green[800],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  '\$${service.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/services/detail',
                                    arguments: service,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
