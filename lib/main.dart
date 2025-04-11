import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/transport_provider.dart';
import 'providers/organic_product_provider.dart';
import 'services/organic_product_service.dart';
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
import 'providers/admin_provider.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin/products_management_screen.dart';
import 'screens/admin/services_management_screen.dart';
import 'screens/admin/organic_products_management_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/transport_management_screen.dart';
import 'config/theme_config.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
        ChangeNotifierProvider(
          create: (context) => OrganicProductProvider(
            OrganicProductService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  bool _tokenLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load the auth token when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tokenLoaded) {
        context.read<AuthProvider>().loadToken();
        _tokenLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Initialize providers with auth token when available
        if (authProvider.token != null) {
          context.read<TransportProvider>().initialize(authProvider.token!);
          context
              .read<OrganicProductProvider>()
              .service
              .setAuthToken(authProvider.token!);
          // Initialize admin provider with auth token
          context.read<AdminProvider>().setAuthToken(authProvider.token!);
        }

        return MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: 'maSOKOtips',
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.getThemeData(),
          initialRoute: '/home',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/cart': (context) => const CartScreen(),
            '/wishlist': (context) => const WishlistScreen(),
            '/orders': (context) => const OrdersScreen(),
            '/profile_test': (context) => const ProfileTestWidget(),
            '/profile': (context) => const ProfileScreen(),
            '/developer_settings': (context) => const DeveloperSettingsScreen(),
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
            '/organic-products/edit': (context) =>
                const EditOrganicProductScreen(),
            '/services': (context) => const ServiceCategoriesScreen(),
            '/services/search': (context) => const ServiceSearchScreen(),
            '/market-info': (context) => const MarketInfoScreen(),
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
                const AdminOrganicProductsManagementScreen(),
            '/admin/users': (context) => const AdminUserManagementScreen(),
            '/admin/transport': (context) =>
                const AdminTransportManagementScreen(),
          },
        );
      },
    );
  }
}
