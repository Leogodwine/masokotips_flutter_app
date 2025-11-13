import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransportServiceScreen extends StatelessWidget {
  final String transportType;
  final Map<String, dynamic> transportDetails;

  const TransportServiceScreen({
    super.key,
    required this.transportType,
    required this.transportDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transportType),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transport Image
            Stack(
              children: [
                Hero(
                  tag: 'transport-$transportType',
                  child: CachedNetworkImage(
                    imageUrl: transportDetails['imageUrl'] as String,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                // Availability Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: transportDetails['isAvailable'] as bool
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      transportDetails['isAvailable'] as bool
                          ? 'Available'
                          : 'Not Available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                  // Transport Details
                  Text(
                    'Transport Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    title: 'Description',
                    content: transportDetails['description'] as String,
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    title: 'Specifications',
                    content: _buildSpecifications(
                      transportDetails['specifications']
                          as Map<String, dynamic>,
                    ),
                    icon: Icons.info,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    title: 'Service Areas',
                    content: (transportDetails['serviceAreas'] as List<String>)
                        .join(', '),
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 24),

                  // Pricing Section
                  Text(
                    'Pricing',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Base Rate: TZS ${transportDetails['baseRate']}/km',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Minimum Distance: ${transportDetails['minDistance']} km',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Additional Charges: ${transportDetails['additionalCharges']}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Provider Section
                  Text(
                    'Contact Provider',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                transportDetails['providerImage'] as String,
                              ),
                            ),
                            title: Text(
                              transportDetails['providerName'] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              transportDetails['providerDescription'] as String,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _makePhoneCall(
                                    transportDetails['providerPhone'] as String,
                                  ),
                                  icon: const Icon(Icons.phone),
                                  label: const Text('Call'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _sendWhatsApp(
                                    transportDetails['providerPhone'] as String,
                                  ),
                                  icon: const FaIcon(FontAwesomeIcons.whatsapp),
                                  label: const Text('WhatsApp'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _sendEmail(
                              transportDetails['providerEmail'] as String,
                            ),
                            icon: const Icon(Icons.email),
                            label: const Text('Send Email'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }

  String _buildSpecifications(Map<String, dynamic> specs) {
    return specs.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber) async {
    final Uri uri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
