import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../models/transport.dart';
import 'transport_details_screen.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';

class TransportListScreen extends StatefulWidget {
  final String category;

  const TransportListScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<TransportListScreen> createState() => _TransportListScreenState();
}

class _TransportListScreenState extends State<TransportListScreen> {
  bool _isLoading = false;
  bool _showFilters = false;
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  String? _selectedProductType;
  double? _minCapacity;
  double? _maxPrice;
  bool? _temperatureControlled;

  final List<String> _productTypes = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Dairy',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Load transports when the screen is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoadTransports();
    });
  }

  Future<void> _initializeAndLoadTransports() async {
    await _loadTransports();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadTransports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TransportProvider>().loadTransports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transports: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final provider = context.read<TransportProvider>();
    provider.setVehicleLocationFilter(_locationController.text);
    provider.setProductTypeFilter(_selectedProductType);
    provider.setCapacityFilter(_minCapacity);
    provider.setPriceFilter(_maxPrice);
    provider.setTemperatureControlledFilter(_temperatureControlled);
  }

  void _clearFilters() {
    setState(() {
      _locationController.clear();
      _selectedProductType = null;
      _minCapacity = null;
      _maxPrice = null;
      _temperatureControlled = null;
    });
    context.read<TransportProvider>().clearFilters();
  }

  Widget _buildFilterPanel() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                decoration: const InputDecoration(
                  labelText: 'Product Type',
                  prefixIcon: Icon(Icons.inventory),
                ),
                items: _productTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Min Capacity (tons)',
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minCapacity = double.tryParse(value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Max Price',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxPrice = double.tryParse(value);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Temperature Controlled'),
                value: _temperatureControlled ?? false,
                onChanged: (value) {
                  setState(() {
                    _temperatureControlled = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Vehicles'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/transport/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_showFilters) _buildFilterPanel(),
                Expanded(
                  child: Consumer<TransportProvider>(
                    builder: (context, transportProvider, child) {
                      final transports = transportProvider.transports;

                      if (transports.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No vehicles available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/transport/add');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Vehicle'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transports.length,
                        itemBuilder: (context, index) {
                          final transport = transports[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransportDetailsScreen(
                                              transport: transport),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              transport.title,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  transport.status == 'active'
                                                      ? Colors.green[100]
                                                      : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              transport.status.toUpperCase(),
                                              style: TextStyle(
                                                color:
                                                    transport.status == 'active'
                                                        ? Colors.green[700]
                                                        : Colors.grey[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            color:
                                                Theme.of(context).primaryColor,
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/transport/edit',
                                                arguments: transport,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: Colors.red,
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  context, transport);
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (transport.imageUrl != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Hero(
                                            tag:
                                                'transport-image-${transport.id}',
                                            child: CachedNetworkImageWithCors(
                                              imageUrl: transport.imageUrl!,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) {
                                                return Container(
                                                  height: 200,
                                                  color: Colors.grey[300],
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.error_outline,
                                                          size: 48,
                                                          color:
                                                              Colors.grey[600]),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Failed to load image',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Location: ${transport.vehicleLocation}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.scale,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Capacity: ${transport.capacity} tons',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          if (transport.isTemperatureControlled)
                                            Icon(
                                              Icons.thermostat,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Owner: ${transport.ownerName}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.drive_eta,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Driver: ${transport.driverName}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (transport.driverRating !=
                                              null) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber[700],
                                            ),
                                            Text(
                                              transport.driverRating!
                                                  .toStringAsFixed(1),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Contact: ${transport.driverPhone}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Visibility(
                                        visible: transport.hasInsurance,
                                        child: Row(
                                          children: [
                                            Icon(Icons.security,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Insured',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            if (transport.insuranceDetails !=
                                                null) ...[
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  transport.insuranceDetails!,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Visibility(
                                        visible:
                                            transport.certifications != null &&
                                                transport
                                                    .certifications!.isNotEmpty,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.verified,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Certifications:',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: transport
                                                  .certifications!
                                                  .map((cert) => Chip(
                                                        label: Text(cert),
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        labelStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                      ))
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            transport.supportedProductTypes
                                                .map((type) => Chip(
                                                      label: Text(type),
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor
                                                              .withOpacity(0.1),
                                                      labelStyle: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ))
                                                .toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Icon(Icons.directions_car,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    transport.vehicleType,
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '\$${transport.price.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (transport.pricePerKg != null)
                                                Text(
                                                  '\$${transport.pricePerKg!.toStringAsFixed(2)}/kg',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: transport.amenities != null &&
                                            transport.amenities!.isNotEmpty,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: transport.amenities!
                                                  .map((amenity) => Chip(
                                                        label: Text(amenity),
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor
                                                                .withOpacity(
                                                                    0.1),
                                                        labelStyle: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                      ))
                                                  .toList(),
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
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, Transport transport) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Transport'),
              content:
                  Text('Are you sure you want to delete ${transport.title}?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      // Disable buttons while deleting
                    });
                    try {
                      await context
                          .read<TransportProvider>()
                          .deleteTransport(transport.id);
                      if (mounted) {
                        Navigator.of(context).pop(); // Close dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transport deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting transport: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
