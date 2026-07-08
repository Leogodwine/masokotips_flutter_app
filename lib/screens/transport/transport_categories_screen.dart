import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'transport_list_screen.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class TransportCategoriesScreen extends StatelessWidget {
  const TransportCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transportCategories = [
      {
        'title': 'Tandem',
        'icon': Icons.local_shipping,
        'description': 'Heavy duty trucks for large loads',
        'image': 'https://picsum.photos/400/200?random=1',
      },
      {
        'title': 'Kirikuu',
        'icon': Icons.delivery_dining,
        'description': 'Medium-sized trucks for local deliveries',
        'image': 'https://picsum.photos/400/200?random=2',
      },
      {
        'title': 'Flatbed Trucks',
        'icon': Icons.airport_shuttle,
        'description': 'Open trucks for construction materials',
        'image': 'https://picsum.photos/400/200?random=3',
      },
      {
        'title': 'Tracker',
        'icon': Icons.directions_car,
        'description': 'Small vehicles for light deliveries',
        'image': 'https://picsum.photos/400/200?random=4',
      },
      {
        'title': 'Box Truck',
        'icon': Icons.local_shipping_outlined,
        'description': 'Enclosed trucks for protected cargo',
        'image': 'https://picsum.photos/400/200?random=5',
      },
      {
        'title': 'Fuso',
        'icon': Icons.local_shipping_outlined,
        'description': 'Medium-duty trucks for various loads',
        'image': 'https://picsum.photos/400/200?random=6',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.transportCategories),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transportCategories.length,
        itemBuilder: (context, index) {
          final category = transportCategories[index];
          return _CategoryCard(category: category);
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransportListScreen(
                category: category['title'] as String,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              child: CachedNetworkImage(
                imageUrl: category['image'] as String,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['description'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.access_time,
                        label: '24/7 Available',
                      ),
                      _InfoChip(
                        icon: Icons.star,
                        label: '4.5+ Rating',
                      ),
                      _InfoChip(
                        icon: Icons.location_on,
                        label: 'Nationwide',
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
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(26),
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
}
