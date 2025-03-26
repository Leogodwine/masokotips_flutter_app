import 'package:flutter/material.dart';

class TransportListScreen extends StatelessWidget {
  final String category;

  const TransportListScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy data - replace with actual API call
    final vehicles = List.generate(
      5,
      (index) => {
        'id': 'vehicle$index',
        'name': '${category} Vehicle ${index + 1}',
        'description':
            'Professional ${category.toLowerCase()} service with experienced driver',
        'image': 'https://picsum.photos/400/200?random=${index + 10}',
        'rating': 4.5 + (index * 0.1).clamp(0, 0.5),
        'reviewCount': 10 + index,
        'price': 1000 + (index * 500),
        'capacity': '${1000 + (index * 500)} kg',
        'availability': 'Available Now',
        'distance': '${2 + index} km away',
        'features': ['GPS Tracking', 'Air Conditioning', 'Loading Assistance'],
        'driver': <String, dynamic>{
          'name': 'Driver ${index + 1}',
          'rating': 4.8,
          'experience': '${5 + index} years',
          'phone': '+254 7XX XXX XXX',
          'verified': true,
        },
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to vehicle details
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child: Image.network(
                      vehicle['image'] as String,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                vehicle['name'] as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Text(
                              'KSh ${vehicle['price']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vehicle['description'] as String,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vehicle['rating']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${vehicle['reviewCount']} reviews)',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoChip(
                              context,
                              icon: Icons.work_outline,
                              label: (vehicle['driver']
                                      as Map<String, dynamic>)['experience']
                                  as String,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              context,
                              icon: Icons.fitness_center,
                              label: vehicle['capacity'] as String,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              context,
                              icon: Icons.person,
                              label: (vehicle['driver']
                                  as Map<String, dynamic>)['name'] as String,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoChip(
                              context,
                              icon: Icons.location_on,
                              label: vehicle['distance'] as String,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              context,
                              icon: Icons.check_circle,
                              label: vehicle['availability'] as String,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final feature
                                in (vehicle['features'] as List<String>))
                              _buildFeatureChip(context, feature),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Implement booking
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: const Text('Book Now'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                // TODO: Implement call driver
                              },
                              icon: const Icon(Icons.phone),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                foregroundColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            feature,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
