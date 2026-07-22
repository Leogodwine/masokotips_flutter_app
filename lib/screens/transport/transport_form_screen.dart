import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/transport.dart';
import '../../providers/transport_provider.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class TransportFormScreen extends StatefulWidget {
  final Transport? transport;

  const TransportFormScreen({
    Key? key,
    this.transport,
  }) : super(key: key);

  @override
  State<TransportFormScreen> createState() => _TransportFormScreenState();
}

class _TransportFormScreenState extends State<TransportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _vehicleLocationController;
  late TextEditingController _priceController;
  late TextEditingController _amenitiesController;
  late TextEditingController _capacityController;
  late TextEditingController _insuranceDetailsController;
  late TextEditingController _ownerNameController;
  late TextEditingController _driverNameController;
  late TextEditingController _driverPhoneController;
  String _status = 'active';
  bool _isTemperatureControlled = false;
  bool _hasInsurance = false;
  List<String> _selectedProductTypes = [];
  final List<String> _productTypes = [
    'Grains',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Dairy',
    'Other'
  ];

  // GPS coordinates
  double? _latitude;
  double? _longitude;
  bool _isCapturingLocation = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.transport?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.transport?.description ?? '');
    _vehicleLocationController =
        TextEditingController(text: widget.transport?.vehicleLocation ?? '');
    _priceController =
        TextEditingController(text: widget.transport?.price.toString() ?? '');
    _amenitiesController = TextEditingController(
      text: widget.transport?.amenities?.join(', ') ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.transport?.capacity.toString() ?? '',
    );
    _insuranceDetailsController = TextEditingController(
      text: widget.transport?.insuranceDetails ?? '',
    );
    _ownerNameController =
        TextEditingController(text: widget.transport?.ownerName ?? '');
    _driverNameController =
        TextEditingController(text: widget.transport?.driverName ?? '');
    _driverPhoneController =
        TextEditingController(text: widget.transport?.driverPhone ?? '');
    _status = widget.transport?.status ?? 'active';
    _isTemperatureControlled =
        widget.transport?.isTemperatureControlled ?? false;
    _hasInsurance = widget.transport?.hasInsurance ?? false;
    _selectedProductTypes = widget.transport?.supportedProductTypes ?? [];
    _latitude = widget.transport?.latitude;
    _longitude = widget.transport?.longitude;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _vehicleLocationController.dispose();
    _priceController.dispose();
    _amenitiesController.dispose();
    _capacityController.dispose();
    _insuranceDetailsController.dispose();
    _ownerNameController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    super.dispose();
  }

  Future<void> _captureCurrentLocation() async {
    setState(() => _isCapturingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.locationServicesAreDisabled)),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.locationPermissionDenied)),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.locationPermissionPermanentlyDeniedEnableIn)),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Location captured: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturingLocation = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final amenities = _amenitiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      if (widget.transport == null) {
        await context.read<TransportProvider>().addTransport(
              title: _titleController.text,
              description: _descriptionController.text,
              vehicleLocation: _vehicleLocationController.text,
              vehicleType: '',
              price: _priceController.text.isNotEmpty ? double.parse(_priceController.text) : 0.0,
              capacity: double.parse(_capacityController.text),
              isTemperatureControlled: _isTemperatureControlled,
              supportedProductTypes: _selectedProductTypes,
              hasInsurance: _hasInsurance,
              insuranceDetails: _insuranceDetailsController.text,
              amenities: amenities,
              status: _status,
              ownerName: _ownerNameController.text,
              driverName: _driverNameController.text,
              driverPhone: _driverPhoneController.text,
              latitude: _latitude,
              longitude: _longitude,
            );
      } else {
        final updatedTransport = widget.transport!.copyWith(
          title: _titleController.text,
          vehicleLocation: _vehicleLocationController.text,
          vehicleType: '',
          price: _priceController.text.isNotEmpty ? double.parse(_priceController.text) : 0.0,
          capacity: double.parse(_capacityController.text),
          isTemperatureControlled: _isTemperatureControlled,
          supportedProductTypes: _selectedProductTypes,
          hasInsurance: _hasInsurance,
          insuranceDetails: _insuranceDetailsController.text,
          amenities: amenities,
          status: _status,
          latitude: _latitude,
          longitude: _longitude,
        );
        await context
            .read<TransportProvider>()
            .updateTransport(updatedTransport);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transport: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.transport == null ? 'Add Transport' : 'Edit Transport'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Describe the transport service',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the owner name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _driverNameController,
              decoration: const InputDecoration(
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.drive_eta_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the driver name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _driverPhoneController,
              decoration: const InputDecoration(
                labelText: 'Driver Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the driver phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vehicleLocationController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Location (City/Area name)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the vehicle location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // ─── GPS Location Capture ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _latitude != null
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                border: Border.all(
                  color: _latitude != null
                      ? Colors.green.shade300
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _latitude != null
                        ? Icons.gps_fixed
                        : Icons.gps_not_fixed,
                    color: _latitude != null ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GPS Coordinates (for map pin)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _latitude != null
                                ? Colors.green.shade800
                                : Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _latitude != null
                              ? '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                              : 'Not captured yet — tap button to set map pin',
                          style: TextStyle(
                            fontSize: 12,
                            color: _latitude != null
                                ? Colors.green.shade700
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isCapturingLocation
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ElevatedButton.icon(
                          onPressed: _captureCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: Text(_latitude != null ? 'Update' : 'Capture'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                ],
              ),
            ),
            // ────────────────────────────────────────────────────────────
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (Optional)',
                border: OutlineInputBorder(),
                prefixText: 'TZS ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amenitiesController,
              decoration: const InputDecoration(
                labelText: 'Amenities (comma-separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., WiFi, AC, USB Ports',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity (tons)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter capacity';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid capacity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.temperatureControlled),
              value: _isTemperatureControlled,
              onChanged: (value) {
                setState(() {
                  _isTemperatureControlled = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _productTypes.map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _selectedProductTypes.contains(type),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedProductTypes.add(type);
                      } else {
                        _selectedProductTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.hasInsurance),
              value: _hasInsurance,
              onChanged: (value) {
                setState(() {
                  _hasInsurance = value;
                });
              },
            ),
            if (_hasInsurance) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _insuranceDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'active',
                  child: Text(AppLocalizations.of(context)!.active),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text(AppLocalizations.of(context)!.inactive),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.transport == null ? 'Add Transport' : 'Update Transport',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
