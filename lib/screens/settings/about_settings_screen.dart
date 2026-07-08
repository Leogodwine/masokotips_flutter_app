import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  static const String _privacyPolicyUrl =
      'https://masokotips.com/privacy-policy.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsAndAbout),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _sectionHeader(context, AppLocalizations.of(context)!.legal),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: Text(AppLocalizations.of(context)!.privacyPolicyMenu),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _openExternalUrl(context, _privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded),
            title: Text(AppLocalizations.of(context)!.requestAccountDeletion),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _composeDeletionEmail(context),
          ),
          const Divider(height: 0),
          const SizedBox(height: 16),
          _sectionHeader(context, AppLocalizations.of(context)!.appTitleSection),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(AppLocalizations.of(context)!.appNameLabel),
            subtitle: Text(AppLocalizations.of(context)!.masokotips),
          ),
          ListTile(
            leading: const Icon(Icons.tag_rounded),
            title: Text(AppLocalizations.of(context)!.versionLabel),
            subtitle: Text(AppLocalizations.of(context)!.seeStoreListingForLatest),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenLink)),
        );
      }
    }
  }

  Future<void> _composeDeletionEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'info@masokotips.com',
      queryParameters: <String, String>{
        'subject': AppLocalizations.of(context)!.accountDeletionRequestSubject,
        'body': AppLocalizations.of(context)!.accountDeletionRequestBody,
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noEmailAppFound)),
        );
      }
    }
  }
}
