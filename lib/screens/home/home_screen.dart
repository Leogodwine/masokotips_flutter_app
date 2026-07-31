import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_content_screen.dart';
import '../../widgets/app_scaffold.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../screens/auth/register_screen.dart'; // Add register screen import
import '../../screens/auth/login_screen.dart'; // Add login screen import
import '../../screens/chat/inbox_screen.dart'; // Add inbox screen import
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load the saved token after the home screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadToken();
    });
  }

  Future<void> _loadToken() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.loadToken();
    } catch (e) {
      debugPrint('Error loading token in HomeScreen: $e');
      // Continue even if token loading fails
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: Text(AppLocalizations.of(context)!.english),
              trailing: localeProvider.isEnglish()
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                localeProvider.setLocaleByCode('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇹🇿', style: TextStyle(fontSize: 24)),
              title: Text(AppLocalizations.of(context)!.kiswahili),
              trailing: localeProvider.isSwahili()
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                localeProvider.setLocaleByCode('sw');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/wishlist');
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxScreen()));
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return PopScope(
      canPop: false,
      child: AppScaffold(
        title: AppLocalizations.of(context)!.homeTitle,
        showBackButton: false,
        body: const HomeContentScreen(),
        currentIndex: _currentIndex,
        onBottomNavItemTapped: _onBottomNavItemTapped,
        showAuthActions:
            false, // Disable default auth buttons since we have custom ones
        actions: [
        // Language Switch Button (visible on all screens)
        Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      localeProvider.isEnglish() ? 'EN' : 'SW',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: () => _showLanguageDialog(context),
              tooltip: 'Change Language',
            );
          },
        ),
        // Prominent Register/Login buttons
        if (!authProvider.isAuthenticated) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(AppLocalizations.of(context)!.register),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(AppLocalizations.of(context)!.login),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    context.watch<SubscriptionProvider>().hasActiveSubscription
                        ? Colors.blue
                        : Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                  context.watch<SubscriptionProvider>().hasActiveSubscription
                      ? 'My Membership'
                      : 'Subscribe Now'),
            ),
          ),
        ],
      ],
      ),
    );
  }
}
