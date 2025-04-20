import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/transport_provider.dart';
import 'providers/market_info_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_test_widget.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/developer_settings_screen.dart';
import 'screens/seller/seller_dashboard_screen.dart';
import 'screens/transport/transport_list_screen.dart';
import 'screens/transport/add_transport_screen.dart';
import 'screens/organic_products_screen.dart';
import 'screens/edit_organic_product_screen.dart';
import 'screens/transport/edit_transport_screen.dart';
import 'screens/provider/add_service_screen.dart';
import 'package:masoko_tips/models/transport.dart';
import 'services/service_service.dart';
import 'screens/services/service_categories_screen.dart';
import 'screens/services/service_search_screen.dart';
import 'screens/admin/market_info_management_screen.dart';
import 'screens/market_info_screen.dart';
import 'screens/admin/create_admin_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/products_management_screen.dart';
import 'screens/admin/services_management_screen.dart';
import 'screens/admin/organic_products_management.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/transport_management_screen.dart';
import 'screens/categories/main_categories_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isAuthenticated) {
          final marketInfoProvider =
              Provider.of<MarketInfoProvider>(context, listen: false);
          marketInfoProvider.setAuthToken(authProvider.token!);

          final productProvider =
              Provider.of<ProductProvider>(context, listen: false);
          productProvider.setAuthToken(authProvider.token!);

          final transportProvider =
              Provider.of<TransportProvider>(context, listen: false);
          transportProvider.initialize(authProvider.token!);

          final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);
          categoryProvider.loadMainCategories();

          final adminProvider =
              Provider.of<AdminProvider>(context, listen: false);
          adminProvider.setAuthToken(authProvider.token!);
        }
      } catch (e, stackTrace) {
        debugPrint('Error in Future.microtask: $e');
        debugPrint('StackTrace: $stackTrace');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketInfoProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'maSOKOtips',
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.getThemeData(),
            home: const HomeScreen(),
            initialRoute: '/home',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/categories': (context) => const MainCategoriesScreen(),
              '/cart': (context) => const CartScreen(),
              '/wishlist': (context) => const WishlistScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/profile_test': (context) => const ProfileTestWidget(),
              '/profile': (context) => const ProfileScreen(),
              '/developer_settings': (context) =>
                  const DeveloperSettingsScreen(),
              '/seller/dashboard': (context) => const SellerDashboardScreen(),
              '/provider/add-service': (context) {
                final serviceService = ServiceService();
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.token != null) {
                  serviceService.setAuthToken(authProvider.token!);
                }
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                final category = args['category'];
                final onServiceAdded = args['onServiceAdded'];
                return AddServiceScreen(
                  onServiceAdded: onServiceAdded,
                  serviceService: serviceService,
                  category: category,
                );
              },
              '/transport/list': (context) =>
                  const TransportListScreen(category: 'all'),
              '/transport/add': (context) => const AddTransportScreen(),
              '/transport/edit': (context) {
                final transport =
                    ModalRoute.of(context)!.settings.arguments as Transport;
                return EditTransportScreen(transport: transport);
              },
              '/organic-products': (context) => const OrganicProductsScreen(),
              '/organic-products/add': (context) =>
                  const EditOrganicProductScreen(),
              '/organic-products/edit': (context) =>
                  const EditOrganicProductScreen(),
              '/services': (context) => const ServiceCategoriesScreen(),
              '/services/search': (context) => const ServiceSearchScreen(),
              '/market-info': (context) => const MarketInfoListScreen(),
              '/admin/market-info': (context) =>
                  const MarketInfoManagementScreen(),
              '/admin/create': (context) => const CreateAdminScreen(),
              '/admin/login': (context) => const AdminLoginScreen(),
              '/admin/dashboard': (context) => const AdminDashboardScreen(),
              '/admin/products': (context) =>
                  const AdminProductsManagementScreen(),
              '/admin/services': (context) =>
                  const AdminServicesManagementScreen(),
              '/admin/organic-products': (context) =>
                  const OrganicProductsManagement(),
              '/admin/users': (context) => const AdminUserManagementScreen(),
              '/admin/transport': (context) =>
                  const AdminTransportManagementScreen(),
            },
          );
        },
      ),
    );
  }
}
