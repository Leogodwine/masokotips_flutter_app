import 'package:flutter/material.dart';
import '../../models/transport.dart';
import 'package:masoko_tips/widgets/cached_network_image_with_cors.dart';

class TransportDetailsScreen extends StatelessWidget {
  final Transport transport;

  const TransportDetailsScreen({
    Key? key,
    required this.transport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: transport.imageUrl != null
                  ? Hero(
                      tag: 'transport-image-${transport.id}',
                      child: CachedNetworkImageWithCors(
                        imageUrl: transport.imageUrl!,
                        fit: BoxFit.cover,
                        height: 300,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.directions_car,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.directions_car,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/transport/edit',
                    arguments: transport,
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          transport.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: transport.status == 'active'
                              ? Colors.green[100]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          transport.status.toUpperCase(),
                          style: TextStyle(
                            color: transport.status == 'active'
                                ? Colors.green[700]
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: 'Vehicle Information',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.directions_car,
                          label: 'Vehicle Type',
                          value: transport.vehicleType ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.scale,
                          label: 'Capacity',
                          value: '${transport.capacity} tons',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.thermostat,
                          label: 'Temperature Control',
                          value:
                              transport.isTemperatureControlled ? 'Yes' : 'No',
                        ),
                        if (transport.temperatureRange != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            icon: Icons.thermostat,
                            label: 'Temperature Range',
                            value: '${transport.temperatureRange}°C',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Location & Contact',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.location_on,
                          label: 'Location',
                          value: transport.vehicleLocation ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.person,
                          label: 'Owner',
                          value: transport.ownerName ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.drive_eta,
                          label: 'Driver',
                          value: transport.driverName ?? 'N/A',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.phone,
                          label: 'Driver Contact',
                          value: transport.driverPhone ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Pricing & Insurance',
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.attach_money,
                          label: 'Base Price',
                          value: '\$${transport.price.toStringAsFixed(2)}',
                        ),
                        if (transport.pricePerKg != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            icon: Icons.monetization_on,
                            label: 'Price per Kg',
                            value:
                                '\$${transport.pricePerKg!.toStringAsFixed(2)}',
                          ),
                        ],
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.security,
                          label: 'Insurance',
                          value: transport.hasInsurance ? 'Yes' : 'No',
                        ),
                        if (transport.insuranceDetails != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            icon: Icons.description,
                            label: 'Insurance Details',
                            value: transport.insuranceDetails!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (transport.supportedProductTypes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Supported Products',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transport.supportedProductTypes.map((type) {
                          return Chip(
                            label: Text(type),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (transport.amenities != null &&
                      transport.amenities!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Amenities',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transport.amenities!.map((amenity) {
                          return Chip(
                            label: Text(amenity),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  if (transport.certifications != null &&
                      transport.certifications!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Certifications',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transport.certifications!.map((cert) {
                          return Chip(
                            label: Text(cert),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement booking functionality
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
