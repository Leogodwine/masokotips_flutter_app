import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../products/product_list_screen.dart';
import '../cart/cart_screen.dart';
import '../../providers/cart_provider.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/category_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../screens/profile/profile_manager.dart';
import '../../utils/logger.dart';
import '../home/home_content_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../categories/main_categories_screen.dart';
import '../transport/transport_categories_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/address_management_screen.dart';
import '../../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/categories');
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
      title: 'Masoko Tips',
      body: const HomeContentScreen(),
      currentIndex: _currentIndex,
      onBottomNavItemTapped: _onBottomNavItemTapped,
    );
  }
}
