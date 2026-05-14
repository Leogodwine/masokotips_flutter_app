import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/models/transport.dart';
import 'package:masoko_tips/providers/transport_provider.dart';
import 'package:masoko_tips/screens/transport/transport_details_screen.dart';

class TransportMapScreen extends StatefulWidget {
  final String category;

  const TransportMapScreen({
    super.key,
    required this.category,
  });

  @override
  State<TransportMapScreen> createState() => _TransportMapScreenState();
}

class _TransportMapScreenState extends State<TransportMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  final Distance _distance = const Distance();

  // Same category mapping as TransportListScreen
  static const Map<String, int> _categoryIds = {
    'Tandem': 13,
    'Kirikuu': 14,
    'Flatbed Trucks': 15,
    'FlatbedTrucks': 15,
    'Tanker': 16,
    'Refrigerator Truck': 17,
    'Box Truck': 18,
    'Liftgate Truck': 19,
    'Van': 20,
    'Container Hauler': 21,
    'Pickups Trucks': 22,
    'Fuso': 23,
    'Semi Trailers': 24,
    'Tracker Trailers': 25,
  };

  int? get _categoryId => _categoryIds[widget.category];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _getCurrentLocation();
    await _loadTransports();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Default to Dar es Salaam if location is disabled
      _setDefaultLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _currentPosition = const LatLng(-6.7924, 39.2083); // Dar es Salaam
      });
    }
  }

  Future<void> _loadTransports() async {
    try {
      await context.read<TransportProvider>().loadTransports(
            categoryId: _categoryId?.toString(),
          );
    } catch (e) {
      debugPrint("Error loading transports for map: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTransportBottomSheet(Transport item) {
    String distanceStr = "Distance unknown";
    if (_currentPosition != null && item.latitude != null && item.longitude != null) {
      final m = _distance.as(
        LengthUnit.Meter,
        _currentPosition!,
        LatLng(item.latitude!, item.longitude!),
      );
      if (m > 1000) {
        distanceStr = "${(m / 1000).toStringAsFixed(1)} km away";
      } else {
        distanceStr = "${m.toStringAsFixed(0)} m away";
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(
                          item.processedImageUrl.isNotEmpty
                              ? item.processedImageUrl
                              : 'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.vehicleType,
                          style: const TextStyle(
                              color: Color(0xFF616161), fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              distanceStr,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
               const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text("Price / Trip",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("TZS ${item.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TransportDetailsScreen(transport: item),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: Text("${widget.category} Map")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final transports = context.watch<TransportProvider>().transports;

    // Build map markers
    final markers = <Marker>[];
    
    // User current position marker
    markers.add(
      Marker(
        point: _currentPosition!,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );

    // Transport markers
    for (var transport in transports) {
      if (transport.latitude != null && transport.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(transport.latitude!, transport.longitude!),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showTransportBottomSheet(transport),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.green,
                  size: 25,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} Map"),
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition!,
          initialZoom: 12.0,
        ),
        children: [
           TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.masoko.tips',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Colors.blue),
        onPressed: () {
          _mapController.move(_currentPosition!, 14.0);
        },
      ),
    );
  }
}
