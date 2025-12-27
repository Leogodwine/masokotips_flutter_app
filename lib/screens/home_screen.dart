import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/category_grid.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load categories when the screen is initialized
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<CategoryProvider>(context, listen: false)
          .loadMainCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    return AppScaffold(
      title: localizations.appTitle,
      currentIndex: 0,
      showAuthActions:
          false, // Disable default auth buttons since we have custom ones
      actions: [
        // Prominent Register/Login buttons
        if (!authProvider.isAuthenticated) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Sign Up'),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Login'),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/subscription');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Subscribe Now'),
            ),
          ),
        ],
      ],
      body: Stack(
        children: [
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (categoryProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        categoryProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          categoryProvider.loadMainCategories();
                        },
                        child: Text(localizations.retry),
                      ),
                    ],
                  ),
                );
              }

              if (categoryProvider.mainCategories.isEmpty) {
                return Center(
                  child: Text(localizations.noCategoriesFound),
                );
              }

              return CategoryGrid(categories: categoryProvider.mainCategories);
            },
          ),
          // Floating Action Button for Subscription
          if (!authProvider.isAuthenticated)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Start Your Journey'),
                      content: const Text(
                        'Sign up to access premium features, exclusive content, and personalized recommendations.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Browse First'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text('Sign Up Now'),
                        ),
                      ],
                    ),
                  );
                },
                backgroundColor: Colors.orange,
                icon: const Icon(Icons.star),
                label: const Text('Get Started'),
              ),
            ),
        ],
      ),
    );
  }
}
