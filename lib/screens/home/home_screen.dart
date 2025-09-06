import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_content_screen.dart';
import '../../widgets/app_scaffold.dart';
import '../../providers/auth_provider.dart';

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
      print('Error loading token in HomeScreen: $e');
      // Continue even if token loading fails
    }
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
        Navigator.pushNamed(context, '/orders');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Home',
      body: const HomeContentScreen(),
      currentIndex: _currentIndex,
      onBottomNavItemTapped: _onBottomNavItemTapped,
    );
  }
}
