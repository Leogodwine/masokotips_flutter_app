import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  static const String _privacyPolicyUrl =
      'https://masokotips.com/privacy-policy.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _sectionHeader(context, 'Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _openExternalUrl(context, _privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: const Text('Request Account Deletion'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _composeDeletionEmail(context),
          ),
          const Divider(height: 0),
          const SizedBox(height: 16),
          _sectionHeader(context, 'App'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('App Name'),
            subtitle: Text('maSOKOtips'),
          ),
          const ListTile(
            leading: Icon(Icons.tag_rounded),
            title: Text('Version'),
            subtitle: Text('See store listing for latest'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  Future<void> _composeDeletionEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'info@masokotips.com',
      queryParameters: <String, String>{
        'subject': 'Account Deletion Request - maSOKOtips',
        'body':
            'Hello maSOKOtips Team,\n\nI would like to request deletion of my account and associated data.'
                '\n\nPlease confirm once completed.\n\nThanks.',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email app found to send request')),
        );
      }
    }
  }
}
