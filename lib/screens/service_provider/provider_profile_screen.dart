import 'package:flutter/material.dart';
import '../../models/provider_profile.dart';
import '../../models/service.dart';
import '../services/service_detail_screen.dart';
import '../chat/chat_screen.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class ProviderProfileScreen extends StatelessWidget {
  final ProviderProfile provider;

  const ProviderProfileScreen({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.name),
        actions: [
          if (provider.isVerified)
            const Icon(
              Icons.verified,
              color: Colors.blue,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  provider.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          provider.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' (${provider.reviewCount})',
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(provider.description),
                  const SizedBox(height: 16),
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(provider.email),
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Email: ${provider.email}')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(provider.phone),
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Phone: ${provider.phone}')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(provider.address),
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Address: ${provider.address}')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Service Categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: provider.serviceCategories.map((category) {
                      return Chip(
                        label: Text(category),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildServicesList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverId: int.tryParse(provider.id) ?? 0,
                receiverName: provider.name,
                receiverImage: provider.imageUrl,
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat),
        label: Text(AppLocalizations.of(context)!.chat),
      ),
    );
  }

  Widget _buildServicesList() {
    // Services feature is under development
    final services = <Service>[];

    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.handyman_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No services available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          child: ListTile(
            leading: service.imageUrl != null
                ? Image.network(
                    service.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image),
                  )
                : const Icon(Icons.image),
            title: Text(service.title ?? 'No Title'),
            subtitle: Text(
              'TZS ${service.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                Text(' ${service.rating?.toStringAsFixed(1) ?? 'N/A'}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(service: service),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
