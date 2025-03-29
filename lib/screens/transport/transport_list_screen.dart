import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import 'transport_details_screen.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';

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
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime? _selectedDate;
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
      _loadTransports();
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadTransports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<TransportProvider>().loadTransports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transports: $e')),
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
    provider.setLocationFilters(_fromController.text, _toController.text);
    provider.setDepartureDateFilter(_selectedDate);
    provider.setProductTypeFilter(_selectedProductType);
    provider.setCapacityFilter(_minCapacity);
    provider.setPriceFilter(_maxPrice);
    provider.setTemperatureControlledFilter(_temperatureControlled);
  }

  void _clearFilters() {
    setState(() {
      _fromController.clear();
      _toController.clear();
      _selectedDate = null;
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
                controller: _fromController,
                decoration: const InputDecoration(
                  labelText: 'From Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _toController,
                decoration: const InputDecoration(
                  labelText: 'To Location',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDate != null
                        ? DateFormat('MMM d, y').format(_selectedDate!)
                        : 'Select Date'),
                  ),
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
                                color: Colors.grey[400],
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
                            child: InkWell(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            transport.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: transport.status == 'active'
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
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (transport.imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Hero(
                                          tag:
                                              'transport-image-${transport.id}',
                                          child: CachedNetworkImageWithCors(
                                            imageUrl: transport.imageUrl!,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) {
                                              return Container(
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${transport.fromLocation} → ${transport.toLocation}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${DateFormat('MMM d, HH:mm').format(transport.departureTime)} - ${DateFormat('MMM d, HH:mm').format(transport.arrivalTime)}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.scale, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Capacity: ${transport.capacity} tons',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 16),
                                        if (transport.isTemperatureControlled)
                                          const Icon(
                                            Icons.thermostat,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Owner: ${transport.ownerName}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.drive_eta, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Driver: ${transport.driverName}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        if (transport.driverRating != null) ...[
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
                                        const Icon(Icons.phone, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Contact: ${transport.driverPhone}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (transport.hasInsurance) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.security, size: 16),
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
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    if (transport.certifications != null &&
                                        transport
                                            .certifications!.isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(Icons.verified, size: 16),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Certifications:',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Wrap(
                                              spacing: 4,
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
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Wrap(
                                      spacing: 8,
                                      children: transport.supportedProductTypes
                                          .map((type) => Chip(
                                                label: Text(type),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ))
                                          .toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.directions_car,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              transport.vehicleType,
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
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
                                    if (transport.amenities != null &&
                                        transport.amenities!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: transport.amenities!
                                            .map((amenity) => Chip(
                                                  label: Text(amenity),
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ],
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
}
