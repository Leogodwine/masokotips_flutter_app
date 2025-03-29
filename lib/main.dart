import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/transport_provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Initialize TransportProvider with auth token when available
          if (authProvider.token != null) {
            context.read<TransportProvider>().initialize(authProvider.token!);
          }

          return MaterialApp(
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'maSOKOtips',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            initialRoute: '/home',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/cart': (context) => const CartScreen(),
              '/wishlist': (context) => const WishlistScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/profile_test': (context) => const ProfileTestWidget(),
              '/profile': (context) => const ProfileScreen(),
              '/developer_settings': (context) =>
                  const DeveloperSettingsScreen(),
              '/seller/dashboard': (context) => const SellerDashboardScreen(),
              '/transport/list': (context) =>
                  const TransportListScreen(category: 'all'),
              '/transport/add': (context) => const AddTransportScreen(),
            },
          );
        },
      ),
    );
  }
}
