import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/models/transport.dart';
import 'package:masoko_tips/providers/transport_provider.dart';
import 'package:masoko_tips/screens/transport/transport_details_screen.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class TransportMapScreen extends StatefulWidget {
  final String category;
  final int? categoryId;
  final Transport? singleTransport;

  const TransportMapScreen({
    super.key,
    this.categoryId,
    required this.category,
    this.singleTransport,
  });

  @override
  State<TransportMapScreen> createState() => _TransportMapScreenState();
}

class _TransportMapScreenState extends State<TransportMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  final Distance _distance = const Distance();

  // Same category mapping as TransportListScreen (Fallback)
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

  int? get _categoryId => widget.categoryId ?? _categoryIds[widget.category];

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
    if (widget.singleTransport != null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
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

  Future<void> _navigateToTransport(Transport item) async {
    if (item.latitude == null || item.longitude == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.thisTruckDoesNotHaveA),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noMapsAppFoundOnThis),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final coords = Coords(item.latitude!, item.longitude!);
    final title = item.title;

    if (!mounted) return;

    if (availableMaps.length == 1) {
      // Only one maps app — open it directly
      await availableMaps.first.showDirections(
        destination: coords,
        destinationTitle: title,
      );
    } else {
      // Multiple maps apps — show picker
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Navigate with...',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...availableMaps.map((map) => ListTile(
                    leading: Image.asset(
                      map.icon,
                      height: 30,
                      width: 30,
                      package: 'map_launcher',
                    ),
                    title: Text(map.mapName),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await map.showDirections(
                        destination: coords,
                        destinationTitle: title,
                      );
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
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
              const SizedBox(height: 16),
              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Price / Trip",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(item.price == 0 ? 'Negotiable' : "TZS ${item.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (item.latitude != null && item.longitude != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.gps_fixed, size: 13, color: Colors.green),
                          SizedBox(width: 4),
                          Text("GPS Set",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Action buttons — always full width so nothing is cut off
              Row(
                children: [
                  if (item.latitude != null && item.longitude != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _navigateToTransport(item);
                        },
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text("Navigate"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(
                              color: Theme.of(context).primaryColor),
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.info_outline,
                          size: 18, color: Colors.white),
                      label: const Text("View Details",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
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
        appBar: AppBar(
            title: Text(widget.singleTransport != null
                ? widget.singleTransport!.title
                : "${widget.category} Map")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final transports = widget.singleTransport != null
        ? [widget.singleTransport!]
        : context.watch<TransportProvider>().transports;

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
        title: Text(widget.singleTransport != null
            ? widget.singleTransport!.title
            : "${widget.category} Map"),
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
