import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'config/theme_config.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/transport_provider.dart';
import 'providers/market_info_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/organic_product_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/subscription_provider.dart';
import 'services/organic_product_service.dart';
import 'services/api_service.dart';
import 'services/market_info_service.dart';
import 'config/api_config.dart';

import 'screens/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';

import 'screens/seller/seller_dashboard_screen.dart';
import 'screens/organic_products_screen.dart';
import 'screens/edit_organic_product_screen.dart';
import 'screens/transport/transport_list_screen.dart';
import 'screens/transport/add_transport_screen.dart';
import 'screens/transport/edit_transport_screen.dart';
import 'screens/provider/add_service_screen.dart';
import 'screens/services/service_categories_screen.dart';
import 'screens/services/service_search_screen.dart';
import 'package:masoko_tips/screens/market_info/market_info_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin/market_info_management_screen.dart';
import 'screens/admin/create_admin_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/products_management_screen.dart';
import 'screens/admin/services_management_screen.dart';
import 'screens/admin/organic_products_management.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/transport_management_screen.dart';
import 'screens/categories/main_categories_screen.dart';
import 'screens/settings/about_settings_screen.dart';
import 'screens/settings/language_settings_screen.dart';

import 'services/service_service.dart';
import 'models/transport.dart';
import 'models/organic_product.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ProxyProvider<AuthProvider, ApiService>(
          create: (context) =>
              ApiService(baseUrl: ApiConfig.baseUrl, apiKey: ''),
          update: (context, auth, previous) {
            final apiService =
                previous ?? ApiService(baseUrl: ApiConfig.baseUrl, apiKey: '');
            if (auth.token != null) {
              apiService.setAuthToken(auth.token!);
            }
            return apiService;
          },
        ),
        ChangeNotifierProvider(
            create: (context) =>
                ProductProvider(apiService: context.read<ApiService>())),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => TransportProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (context) => OrdersProvider(),
          update: (context, authProvider, previous) {
            final ordersProvider = previous ?? OrdersProvider();
            if (authProvider.token != null) {
              final apiService = ApiService(
                baseUrl: ApiConfig.baseUrl,
                apiKey: authProvider.token!,
              );
              apiService.setAuthToken(authProvider.token!);
              ordersProvider.setApiService(apiService);
            }
            return ordersProvider;
          },
        ),
        ChangeNotifierProxyProvider<ApiService, MarketInfoProvider>(
          create: (context) => MarketInfoProvider(
              marketInfoService: MarketInfoService(context.read<ApiService>())),
          update: (context, apiService, previous) => MarketInfoProvider(
            marketInfoService: MarketInfoService(apiService),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrganicProductProvider>(
          create: (context) => OrganicProductProvider(OrganicProductService()),
          update: (context, authProvider, previous) {
            final service = OrganicProductService();
            if (authProvider.token != null) {
              service.setAuthToken(authProvider.token!);
            }
            return OrganicProductProvider(service);
          },
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            key: ValueKey(
                'app_${localeProvider.locale.languageCode}'), // Force rebuild when locale changes
            title: 'maSOKOtips',
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.getThemeData(),
            scaffoldMessengerKey: scaffoldMessengerKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: localeProvider.locale,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // Use the user-selected locale instead of device locale
              return localeProvider.locale;
            },
            home:
                const SplashScreen(), // ✅ Brief custom splash for sponsors after native splash
            routes: {
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/cart': (context) => const CartScreen(),
              '/wishlist': (context) => const WishlistScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/seller/dashboard': (context) => const SellerDashboardScreen(),
              '/organic-products': (context) => const OrganicProductsScreen(),
              '/organic-products/add': (context) =>
                  const EditOrganicProductScreen(),
              '/organic-products/edit': (context) {
                final product = ModalRoute.of(context)!.settings.arguments
                    as OrganicProduct;
                return EditOrganicProductScreen(product: product);
              },
              '/transport/list': (context) =>
                  const TransportListScreen(category: 'all'),
              '/transport/add': (context) => const AddTransportScreen(),
              '/transport/edit': (context) {
                final transport =
                    ModalRoute.of(context)!.settings.arguments as Transport;
                return EditTransportScreen(transport: transport);
              },
              '/services': (context) => const ServiceCategoriesScreen(),
              '/services/search': (context) => const ServiceSearchScreen(),
              '/market-info': (context) => const MarketInfoScreen(),
              '/settings': (context) => const AboutSettingsScreen(),
              '/settings/language': (context) => const LanguageSettingsScreen(),
              '/admin/dashboard': (context) => const AdminDashboardScreen(),
              '/admin/market-info': (context) =>
                  const MarketInfoManagementScreen(),
              '/admin/create': (context) => const CreateAdminScreen(),
              '/admin/login': (context) => const AdminLoginScreen(),
              '/admin/products': (context) =>
                  const AdminProductsManagementScreen(),
              '/admin/services': (context) =>
                  const AdminServicesManagementScreen(),
              '/admin/organic-products': (context) =>
                  const OrganicProductsManagement(),
              '/admin/users': (context) => const AdminUserManagementScreen(),
              '/admin/transport': (context) =>
                  const AdminTransportManagementScreen(),
              '/categories': (context) => const MainCategoriesScreen(),
              '/provider/add-service': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                final category = args['category'];
                final onServiceAdded = args['onServiceAdded'];

                final serviceService = ServiceService();
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.token != null) {
                  serviceService.setAuthToken(authProvider.token!);
                }

                return AddServiceScreen(
                  onServiceAdded: onServiceAdded,
                  serviceService: serviceService,
                  category: category,
                );
              },
            },
          );
        },
      ),
    );
  }
}
