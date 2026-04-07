import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'maSOKOtips'**
  String get appTitle;

  /// Title for the login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Welcome back message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Sign in to continue message
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Placeholder text for username field
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// Error message for missing username
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequired;

  /// Error message for username too short
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder text for password field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Error message for missing password
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// Text asking if user has no account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get register;

  /// Description for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Description for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Description for cart
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// Description for orders
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Description for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Description for myProfile
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Description for guestUser
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// Description for loginRegister
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get loginRegister;

  /// Description for account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Description for personalDetails
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// Description for requestAccountDeletion
  ///
  /// In en, this message translates to:
  /// **'Request Account Deletion'**
  String get requestAccountDeletion;

  /// Description for sellerDashboard
  ///
  /// In en, this message translates to:
  /// **'Seller Dashboard'**
  String get sellerDashboard;

  /// Description for serviceProviderDashboard
  ///
  /// In en, this message translates to:
  /// **'Service Provider Dashboard'**
  String get serviceProviderDashboard;

  /// Description for manageAddresses
  ///
  /// In en, this message translates to:
  /// **'Manage Addresses'**
  String get manageAddresses;

  /// Description for myOrders
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// Description for myFavorites
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// Description for appSettings
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Description for notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Description for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Description for englishKiswahili
  ///
  /// In en, this message translates to:
  /// **'English / Kiswahili'**
  String get englishKiswahili;

  /// Description for helpSupport
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Description for developerSettings
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get developerSettings;

  /// Description for about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Description for privacyPolicy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Description for marketInformation
  ///
  /// In en, this message translates to:
  /// **'Market Information'**
  String get marketInformation;

  /// Description for logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Description for loginRequired
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// Description for loginRequiredMessage
  ///
  /// In en, this message translates to:
  /// **'You need to login to access this feature. Would you like to login now?'**
  String get loginRequiredMessage;

  /// Description for later
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get later;

  /// Text for login button
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// Description for admin
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Description for seller
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get seller;

  /// Description for serviceProvider
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get serviceProvider;

  /// Description for buyer
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyer;

  /// Description for editProfile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Description for addresses
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// Description for logoutConfirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Description for homeTitle
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// Description for appName
  ///
  /// In en, this message translates to:
  /// **'maSOKOtips'**
  String get appName;

  /// Description for appSubtitle
  ///
  /// In en, this message translates to:
  /// **'Tanzania\'s Premier Agricultural Marketplace'**
  String get appSubtitle;

  /// Description for poweredBy
  ///
  /// In en, this message translates to:
  /// **'Sponsored by: COSTECH'**
  String get poweredBy;

  /// Description for costech
  ///
  /// In en, this message translates to:
  /// **'National Institute of Science and Technology (COSTECH)'**
  String get costech;

  /// Description for serviceProviderUnavailable
  ///
  /// In en, this message translates to:
  /// **'Service provider dashboard is currently unavailable'**
  String get serviceProviderUnavailable;

  /// Description for notificationsComingSoon
  ///
  /// In en, this message translates to:
  /// **'Notifications settings coming soon'**
  String get notificationsComingSoon;

  /// Description for helpSupportComingSoon
  ///
  /// In en, this message translates to:
  /// **'Help & Support coming soon'**
  String get helpSupportComingSoon;

  /// Description for noEmailApp
  ///
  /// In en, this message translates to:
  /// **'No email app found to send request'**
  String get noEmailApp;

  /// Description for couldNotOpenLink
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// Description for loggedOutSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get loggedOutSuccessfully;

  /// Description for logoutFailed
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get logoutFailed;

  /// Description for masokoTips
  ///
  /// In en, this message translates to:
  /// **'Masoko Tips'**
  String get masokoTips;

  /// Description for copyright
  ///
  /// In en, this message translates to:
  /// **'Â© 2023 Masoko Tips - All rights reserved'**
  String get copyright;

  /// Description for aboutDescription
  ///
  /// In en, this message translates to:
  /// **'Masoko Tips is a platform connecting buyers and sellers of agricultural products. Our mission is to promote sustainable farming and fair trade practices.'**
  String get aboutDescription;

  /// Description for aboutContact
  ///
  /// In en, this message translates to:
  /// **'For more information, contact us at support@masokotips.com'**
  String get aboutContact;

  /// Description for pleaseLoginToEditProfile
  ///
  /// In en, this message translates to:
  /// **'Please login to edit your profile'**
  String get pleaseLoginToEditProfile;

  /// Description for errorPickingImage
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// Description for photoLibrary
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// Description for camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Description for removePhoto
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Description for profileUpdatedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Description for failedToUpdateProfile
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// Description for emailAlreadyRegistered
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please use a different email address.'**
  String get emailAlreadyRegistered;

  /// Description for fullName
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Description for phoneNumber
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Description for bio
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Description for tellUsAboutYourself
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// Description for saveChanges
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// Description for failedToLoadAddresses
  ///
  /// In en, this message translates to:
  /// **'Failed to load addresses'**
  String get failedToLoadAddresses;

  /// Description for deleteAddress
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// Description for confirmDeleteAddress
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get confirmDeleteAddress;

  /// Description for cancel
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// Description for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Description for addressDeleted
  ///
  /// In en, this message translates to:
  /// **'Address deleted'**
  String get addressDeleted;

  /// Description for defaultAddressUpdated
  ///
  /// In en, this message translates to:
  /// **'Default address updated'**
  String get defaultAddressUpdated;

  /// Description for noAddressesFound
  ///
  /// In en, this message translates to:
  /// **'No addresses found'**
  String get noAddressesFound;

  /// Description for addNewAddress
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// Description for edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Description for setAsDefault
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// Description for addAddress
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get addAddress;

  /// Description for editAddress
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// Description for addressName
  ///
  /// In en, this message translates to:
  /// **'Address Name'**
  String get addressName;

  /// Description for addressNameHint
  ///
  /// In en, this message translates to:
  /// **'Home, Work, etc.'**
  String get addressNameHint;

  /// Description for streetAddress
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// Description for streetAddressHint
  ///
  /// In en, this message translates to:
  /// **'123 Main St'**
  String get streetAddressHint;

  /// Description for city
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Description for stateProvince
  ///
  /// In en, this message translates to:
  /// **'State/Province'**
  String get stateProvince;

  /// Description for zipPostalCode
  ///
  /// In en, this message translates to:
  /// **'ZIP/Postal Code'**
  String get zipPostalCode;

  /// Description for country
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// Description for setAsDefaultAddress
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setAsDefaultAddress;

  /// Description for defaultAddressDescription
  ///
  /// In en, this message translates to:
  /// **'This address will be selected by default during checkout'**
  String get defaultAddressDescription;

  /// Description for saveAddress
  ///
  /// In en, this message translates to:
  /// **'SAVE ADDRESS'**
  String get saveAddress;

  /// Description for enterAddressName
  ///
  /// In en, this message translates to:
  /// **'Please enter an address name'**
  String get enterAddressName;

  /// Description for enterStreetAddress
  ///
  /// In en, this message translates to:
  /// **'Please enter a street address'**
  String get enterStreetAddress;

  /// Description for enterCity
  ///
  /// In en, this message translates to:
  /// **'Please enter a city'**
  String get enterCity;

  /// Description for enterState
  ///
  /// In en, this message translates to:
  /// **'Please enter a state'**
  String get enterState;

  /// Description for enterZipCode
  ///
  /// In en, this message translates to:
  /// **'Please enter a ZIP code'**
  String get enterZipCode;

  /// Description for enterCountry
  ///
  /// In en, this message translates to:
  /// **'Please enter a country'**
  String get enterCountry;

  /// Description for description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Description for addToCart
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// Description for relatedProducts
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get relatedProducts;

  /// Description for noRelatedProducts
  ///
  /// In en, this message translates to:
  /// **'No related products available'**
  String get noRelatedProducts;

  /// Description for addedToCart
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String addedToCart(String productName);

  /// Description for failedToAddToCart
  ///
  /// In en, this message translates to:
  /// **'Failed to add to cart: {error}'**
  String failedToAddToCart(String error);

  /// Description for noProductsInCategory
  ///
  /// In en, this message translates to:
  /// **'No products available in this category'**
  String get noProductsInCategory;

  /// Description for checkBackLater
  ///
  /// In en, this message translates to:
  /// **'Please check back later'**
  String get checkBackLater;

  /// Description for errorLoadingProducts
  ///
  /// In en, this message translates to:
  /// **'Unable to load products. Please check your connection and try again.'**
  String get errorLoadingProducts;

  /// Description for retry
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// Description for inStock
  ///
  /// In en, this message translates to:
  /// **'{stock} in stock'**
  String inStock(num stock);

  /// Description for organicProducts
  ///
  /// In en, this message translates to:
  /// **'Organic Products'**
  String get organicProducts;

  /// Description for sortAndFilter
  ///
  /// In en, this message translates to:
  /// **'Sort & Filter'**
  String get sortAndFilter;

  /// Description for sortBy
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// Description for nameAZ
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// Description for nameZA
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// Description for priceLowHigh
  ///
  /// In en, this message translates to:
  /// **'Price (Low-High)'**
  String get priceLowHigh;

  /// Description for priceHighLow
  ///
  /// In en, this message translates to:
  /// **'Price (High-Low)'**
  String get priceHighLow;

  /// Description for showInStockOnly
  ///
  /// In en, this message translates to:
  /// **'Show In Stock Only'**
  String get showInStockOnly;

  /// Description for close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Description for searchOrganicProducts
  ///
  /// In en, this message translates to:
  /// **'Search organic products...'**
  String get searchOrganicProducts;

  /// Description for errorLoadingOrganicProducts
  ///
  /// In en, this message translates to:
  /// **'Error loading organic products: {error}'**
  String errorLoadingOrganicProducts(String error);

  /// Description for noOrganicProductsFound
  ///
  /// In en, this message translates to:
  /// **'No organic products found'**
  String get noOrganicProductsFound;

  /// Description for deleteProduct
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// Description for confirmDeleteProduct
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {productName}?'**
  String confirmDeleteProduct(String productName);

  /// Description for productDeletedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'{productName} deleted successfully'**
  String productDeletedSuccessfully(String productName);

  /// Description for errorDeletingProduct
  ///
  /// In en, this message translates to:
  /// **'Error deleting product: {error}'**
  String errorDeletingProduct(String error);

  /// Description for shoppingCart
  ///
  /// In en, this message translates to:
  /// **'Shopping Cart'**
  String get shoppingCart;

  /// Description for clearCart
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// Description for confirmClearCart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your cart?'**
  String get confirmClearCart;

  /// Description for pleaseLoginToViewCart
  ///
  /// In en, this message translates to:
  /// **'Please login to view your cart'**
  String get pleaseLoginToViewCart;

  /// Description for yourCartIsEmpty
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// Description for continueShopping
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get continueShopping;

  /// Description for itemRemovedFromCart
  ///
  /// In en, this message translates to:
  /// **'Item removed from cart'**
  String get itemRemovedFromCart;

  /// Description for removeItem
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get removeItem;

  /// Description for confirmRemoveItem
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item from your cart?'**
  String get confirmRemoveItem;

  /// Description for total
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get total;

  /// Description for proceedToCheckout
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// Description for checkout
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// Description for pleaseLoginToPlaceOrder
  ///
  /// In en, this message translates to:
  /// **'Please log in to place an order'**
  String get pleaseLoginToPlaceOrder;

  /// Description for failedToPlaceOrder
  ///
  /// In en, this message translates to:
  /// **'Failed to place order: {error}'**
  String failedToPlaceOrder(String error);

  /// Description for orderSummary
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// Description for deliveryInformation
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// Description for deliveryMethod
  ///
  /// In en, this message translates to:
  /// **'Delivery Method'**
  String get deliveryMethod;

  /// Description for standardDelivery
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery'**
  String get standardDelivery;

  /// Description for standardDeliveryTime
  ///
  /// In en, this message translates to:
  /// **'3-5 business days'**
  String get standardDeliveryTime;

  /// Description for expressDelivery
  ///
  /// In en, this message translates to:
  /// **'Express Delivery'**
  String get expressDelivery;

  /// Description for expressDeliveryTime
  ///
  /// In en, this message translates to:
  /// **'1-2 business days'**
  String get expressDeliveryTime;

  /// Description for deliveryAddress
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// Description for pleaseSelectDeliveryAddress
  ///
  /// In en, this message translates to:
  /// **'Please select delivery address'**
  String get pleaseSelectDeliveryAddress;

  /// Description for phoneNumberHint
  ///
  /// In en, this message translates to:
  /// **'+255 123 456 789'**
  String get phoneNumberHint;

  /// Description for phoneNumberRequired
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// Description for paymentMethod
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Description for cashOnDelivery
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// Description for cashOnDeliveryDescription
  ///
  /// In en, this message translates to:
  /// **'Pay when you receive your order'**
  String get cashOnDeliveryDescription;

  /// Description for creditDebitCard
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Card'**
  String get creditDebitCard;

  /// Description for creditDebitCardDescription
  ///
  /// In en, this message translates to:
  /// **'Secure online payment'**
  String get creditDebitCardDescription;

  /// Description for orderNotesOptional
  ///
  /// In en, this message translates to:
  /// **'Order Notes (Optional)'**
  String get orderNotesOptional;

  /// Description for orderNotesHint
  ///
  /// In en, this message translates to:
  /// **'Any special instructions for your order...'**
  String get orderNotesHint;

  /// Description for placeOrder
  ///
  /// In en, this message translates to:
  /// **'PLACE ORDER - TZS {total}'**
  String placeOrder(num total);

  /// Description for selectAddress
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get selectAddress;

  /// Description for sellerDashboardTitle
  ///
  /// In en, this message translates to:
  /// **'Seller Dashboard'**
  String get sellerDashboardTitle;

  /// Description for productsTab
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTab;

  /// Description for ordersTab
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTab;

  /// Description for transportsTab
  ///
  /// In en, this message translates to:
  /// **'Transports'**
  String get transportsTab;

  /// Description for organicTab
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get organicTab;

  /// Description for servicesTab
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTab;

  /// Description for addProduct
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// Description for noProductsFound
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Description for filterByCategory
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// Description for outOfStock
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// Description for failedToDeleteProduct
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product: {error}'**
  String failedToDeleteProduct(String error);

  /// Description for failedToLoadProducts
  ///
  /// In en, this message translates to:
  /// **'Failed to load products: {error}'**
  String failedToLoadProducts(String error);

  /// Description for addNewProduct
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addNewProduct;

  /// Description for productName
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// Description for enterProductName
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name'**
  String get enterProductName;

  /// Description for productDescription
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// Description for enterDescription
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get enterDescription;

  /// Description for productPrice
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPrice;

  /// Description for required
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Description for invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// Description for stock
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// Description for enterStockQuantity
  ///
  /// In en, this message translates to:
  /// **'Please enter stock quantity'**
  String get enterStockQuantity;

  /// Description for invalidStockQuantity
  ///
  /// In en, this message translates to:
  /// **'Invalid stock quantity'**
  String get invalidStockQuantity;

  /// Description for category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Description for productImages
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImages;

  /// Description for addImages
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// Description for imagesSelected
  ///
  /// In en, this message translates to:
  /// **'{count} image(s) selected'**
  String imagesSelected(num count);

  /// Description for productAddedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccessfully;

  /// Description for failedToAddProduct
  ///
  /// In en, this message translates to:
  /// **'Failed to add product: {error}'**
  String failedToAddProduct(String error);

  /// Description for editProduct
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// Description for enterProductDescription
  ///
  /// In en, this message translates to:
  /// **'Please enter a product description'**
  String get enterProductDescription;

  /// Description for invalidPrice
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get invalidPrice;

  /// Description for updateProduct
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// Description for productUpdatedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// Description for productDeleted
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeleted;

  /// Description for myOrganicProducts
  ///
  /// In en, this message translates to:
  /// **'My Organic Products'**
  String get myOrganicProducts;

  /// Description for apiServiceNotInitialized
  ///
  /// In en, this message translates to:
  /// **'API service not initialized'**
  String get apiServiceNotInitialized;

  /// Description for failedToFetchOrganicProducts
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch organic products'**
  String get failedToFetchOrganicProducts;

  /// Description for noOrganicProductsYet
  ///
  /// In en, this message translates to:
  /// **'No Organic Products Yet'**
  String get noOrganicProductsYet;

  /// Description for startAddingOrganicProduct
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first organic product'**
  String get startAddingOrganicProduct;

  /// Description for addOrganicProduct
  ///
  /// In en, this message translates to:
  /// **'Add Organic Product'**
  String get addOrganicProduct;

  /// Description for stockLabel
  ///
  /// In en, this message translates to:
  /// **'Stock: {stock}'**
  String stockLabel(num stock);

  /// Description for certified
  ///
  /// In en, this message translates to:
  /// **'Certified: {certification}'**
  String certified(String certification);

  /// Description for active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Description for inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Description for featured
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// Description for deleteOrganicProduct
  ///
  /// In en, this message translates to:
  /// **'Delete Organic Product'**
  String get deleteOrganicProduct;

  /// Description for confirmDeleteOrganicProduct
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{productName}\"? This action cannot be undone.'**
  String confirmDeleteOrganicProduct(String productName);

  /// Description for failedToDeleteOrganicProduct
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product: {error}'**
  String failedToDeleteOrganicProduct(String error);

  /// Description for myTransportServices
  ///
  /// In en, this message translates to:
  /// **'My Transport Services'**
  String get myTransportServices;

  /// Description for addTransport
  ///
  /// In en, this message translates to:
  /// **'Add Transport'**
  String get addTransport;

  /// Description for errorLoadingTransports
  ///
  /// In en, this message translates to:
  /// **'Error Loading Transports'**
  String get errorLoadingTransports;

  /// Description for noTransportServicesYet
  ///
  /// In en, this message translates to:
  /// **'No Transport Services Yet'**
  String get noTransportServicesYet;

  /// Description for addTransportServicesDescription
  ///
  /// In en, this message translates to:
  /// **'Add your transport services to start offering delivery and transportation to customers.'**
  String get addTransportServicesDescription;

  /// Description for addYourFirstTransport
  ///
  /// In en, this message translates to:
  /// **'Add Your First Transport'**
  String get addYourFirstTransport;

  /// Description for capacityKg
  ///
  /// In en, this message translates to:
  /// **'{capacity} kg capacity'**
  String capacityKg(num capacity);

  /// Description for pricePerKg
  ///
  /// In en, this message translates to:
  /// **'TZS {price}/kg'**
  String pricePerKg(num price);

  /// Description for noDescriptionAvailable
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// Description for deleteTransportService
  ///
  /// In en, this message translates to:
  /// **'Delete Transport Service'**
  String get deleteTransportService;

  /// Description for confirmDeleteTransport
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This action cannot be undone.'**
  String confirmDeleteTransport(String title);

  /// Description for transportDeletedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'{title} deleted successfully'**
  String transportDeletedSuccessfully(String title);

  /// Description for failedToDeleteTransport
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transport: {error}'**
  String failedToDeleteTransport(String error);

  /// Description for editTransportService
  ///
  /// In en, this message translates to:
  /// **'Edit Transport Service'**
  String get editTransportService;

  /// Description for save
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// Description for basicInformation
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Description for serviceTitle
  ///
  /// In en, this message translates to:
  /// **'Service Title'**
  String get serviceTitle;

  /// Description for serviceTitleHint
  ///
  /// In en, this message translates to:
  /// **'e.g., Reliable Delivery Truck'**
  String get serviceTitleHint;

  /// Description for describeService
  ///
  /// In en, this message translates to:
  /// **'Describe your transport service...'**
  String get describeService;

  /// Description for enterServiceTitle
  ///
  /// In en, this message translates to:
  /// **'Please enter a service title'**
  String get enterServiceTitle;

  /// Description for enterServiceDescription
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get enterServiceDescription;

  /// Description for vehicleDetails
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// Description for vehicleType
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// Description for vehicleLocation
  ///
  /// In en, this message translates to:
  /// **'Vehicle Location'**
  String get vehicleLocation;

  /// Description for vehicleLocationHint
  ///
  /// In en, this message translates to:
  /// **'e.g., Dar es Salaam, Tanzania'**
  String get vehicleLocationHint;

  /// Description for enterVehicleLocation
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle location'**
  String get enterVehicleLocation;

  /// Description for pricePerKm
  ///
  /// In en, this message translates to:
  /// **'Price per KM'**
  String get pricePerKm;

  /// Description for enterPrice
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// Description for enterValidPrice
  ///
  /// In en, this message translates to:
  /// **'Enter valid price'**
  String get enterValidPrice;

  /// Description for capacityKgLabel
  ///
  /// In en, this message translates to:
  /// **'Capacity (kg)'**
  String get capacityKgLabel;

  /// Description for enterCapacity
  ///
  /// In en, this message translates to:
  /// **'Enter capacity'**
  String get enterCapacity;

  /// Description for enterValidCapacity
  ///
  /// In en, this message translates to:
  /// **'Enter valid capacity'**
  String get enterValidCapacity;

  /// Description for contactInformation
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// Description for contactPhone
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// Description for contactPhoneHint
  ///
  /// In en, this message translates to:
  /// **'e.g., +255 123 456 789'**
  String get contactPhoneHint;

  /// Description for enterContactPhone
  ///
  /// In en, this message translates to:
  /// **'Please enter contact phone'**
  String get enterContactPhone;

  /// Description for status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Description for updateTransportService
  ///
  /// In en, this message translates to:
  /// **'Update Transport Service'**
  String get updateTransportService;

  /// Description for transportUpdatedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Transport service updated successfully!'**
  String get transportUpdatedSuccessfully;

  /// Description for failedToUpdateTransport
  ///
  /// In en, this message translates to:
  /// **'Failed to update transport: {error}'**
  String failedToUpdateTransport(String error);

  /// Description for sellerOrders
  ///
  /// In en, this message translates to:
  /// **'Seller Orders'**
  String get sellerOrders;

  /// Description for errorLoadingOrders
  ///
  /// In en, this message translates to:
  /// **'Error Loading Orders'**
  String get errorLoadingOrders;

  /// Description for noOrdersYet
  ///
  /// In en, this message translates to:
  /// **'No Orders Yet'**
  String get noOrdersYet;

  /// Description for ordersDescription
  ///
  /// In en, this message translates to:
  /// **'Orders from customers will appear here once they start purchasing your products.'**
  String get ordersDescription;

  /// Description for refreshOrders
  ///
  /// In en, this message translates to:
  /// **'Refresh Orders'**
  String get refreshOrders;

  /// Description for orderNumber
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderNumber(String id);

  /// Description for totalAmount
  ///
  /// In en, this message translates to:
  /// **'Total: TZS {amount}'**
  String totalAmount(num amount);

  /// Description for itemsCount
  ///
  /// In en, this message translates to:
  /// **'Items: {count}'**
  String itemsCount(num count);

  /// Description for orderDate
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String orderDate(String date);

  /// Description for markAsProcessing
  ///
  /// In en, this message translates to:
  /// **'Mark as Processing'**
  String get markAsProcessing;

  /// Description for markAsShipped
  ///
  /// In en, this message translates to:
  /// **'Mark as Shipped'**
  String get markAsShipped;

  /// Description for markAsDelivered
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markAsDelivered;

  /// Description for orderDelivered
  ///
  /// In en, this message translates to:
  /// **'Order Delivered'**
  String get orderDelivered;

  /// Description for orderCancelled
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// Description for orderStatusUpdated
  ///
  /// In en, this message translates to:
  /// **'Order status updated to {status}'**
  String orderStatusUpdated(String status);

  /// Description for failedToUpdateOrderStatus
  ///
  /// In en, this message translates to:
  /// **'Failed to update order status'**
  String get failedToUpdateOrderStatus;

  /// Description for errorUpdatingOrderStatus
  ///
  /// In en, this message translates to:
  /// **'Error updating order status: {error}'**
  String errorUpdatingOrderStatus(String error);

  /// Description for emailLabel
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailLabel(String email);

  /// Description for phoneLabel
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabel(String phone);

  /// Description for addressLabel
  ///
  /// In en, this message translates to:
  /// **'Address: {address}'**
  String addressLabel(String address);

  /// Description for serviceCategories
  ///
  /// In en, this message translates to:
  /// **'Service Categories'**
  String get serviceCategories;

  /// Description for services
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// Description for noServicesAvailable
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get noServicesAvailable;

  /// Description for chat
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Description for noTitle
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get noTitle;

  /// Description for notAvailable
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// Description for addNewService
  ///
  /// In en, this message translates to:
  /// **'Add New Service'**
  String get addNewService;

  /// Description for createYourService
  ///
  /// In en, this message translates to:
  /// **'Create Your Service'**
  String get createYourService;

  /// Description for fillServiceDetails
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to offer your agricultural service'**
  String get fillServiceDetails;

  /// Description for serviceTitleExample
  ///
  /// In en, this message translates to:
  /// **'e.g., Irrigation System Installation'**
  String get serviceTitleExample;

  /// Description for enterTitle
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// Description for describeServiceDetail
  ///
  /// In en, this message translates to:
  /// **'Describe your service in detail...'**
  String get describeServiceDetail;

  /// Description for priceTzs
  ///
  /// In en, this message translates to:
  /// **'Price (TZS)'**
  String get priceTzs;

  /// Description for enterServicePrice
  ///
  /// In en, this message translates to:
  /// **'Enter service price'**
  String get enterServicePrice;

  /// Description for enterValidServicePrice
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get enterValidServicePrice;

  /// Description for agriculturalServiceCategory
  ///
  /// In en, this message translates to:
  /// **'Agricultural Service Category'**
  String get agriculturalServiceCategory;

  /// Description for selectCategory
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// Description for loadingCategories
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get loadingCategories;

  /// Description for serviceImage
  ///
  /// In en, this message translates to:
  /// **'Service Image'**
  String get serviceImage;

  /// Description for addImageToService
  ///
  /// In en, this message translates to:
  /// **'Add an image to make your service more appealing'**
  String get addImageToService;

  /// Description for chooseImage
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get chooseImage;

  /// Description for creatingService
  ///
  /// In en, this message translates to:
  /// **'Creating Service...'**
  String get creatingService;

  /// Description for createService
  ///
  /// In en, this message translates to:
  /// **'Create Service'**
  String get createService;

  /// Description for selectCategoryError
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategoryError;

  /// Description for failedToLoadCategories
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories: {error}'**
  String failedToLoadCategories(String error);

  /// Description for editService
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// Description for changeServiceImage
  ///
  /// In en, this message translates to:
  /// **'Change Service Image'**
  String get changeServiceImage;

  /// Description for updateService
  ///
  /// In en, this message translates to:
  /// **'Update Service'**
  String get updateService;

  /// Description for myAgriculturalServices
  ///
  /// In en, this message translates to:
  /// **'My Agricultural Services'**
  String get myAgriculturalServices;

  /// Description for serviceProviderRoleRequired
  ///
  /// In en, this message translates to:
  /// **'You need to have Service Provider role to manage services.'**
  String get serviceProviderRoleRequired;

  /// Description for failedToLoadServices
  ///
  /// In en, this message translates to:
  /// **'Failed to load services: {error}'**
  String failedToLoadServices(String error);

  /// Description for noServicesYet
  ///
  /// In en, this message translates to:
  /// **'No Services Yet'**
  String get noServicesYet;

  /// Description for startOfferingServices
  ///
  /// In en, this message translates to:
  /// **'Start offering agricultural services to farmers and grow your business'**
  String get startOfferingServices;

  /// Description for addYourFirstService
  ///
  /// In en, this message translates to:
  /// **'Add Your First Service'**
  String get addYourFirstService;

  /// Description for noDescription
  ///
  /// In en, this message translates to:
  /// **'No Description'**
  String get noDescription;

  /// Description for servicePrice
  ///
  /// In en, this message translates to:
  /// **'TZS {price}'**
  String servicePrice(num price);

  /// Description for pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Description for editServiceLabel
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editServiceLabel;

  /// Description for deleteServiceLabel
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteServiceLabel;

  /// Description for confirmDeleteService
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String confirmDeleteService(String title);

  /// Description for serviceDeletedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Service deleted successfully'**
  String get serviceDeletedSuccessfully;

  /// Description for failedToDeleteService
  ///
  /// In en, this message translates to:
  /// **'Failed to delete service: {error}'**
  String failedToDeleteService(String error);

  /// Description for addService
  ///
  /// In en, this message translates to:
  /// **'Add Service'**
  String get addService;

  /// Description for welcomeTo
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// Description for agricultureDescription
  ///
  /// In en, this message translates to:
  /// **'Everything you need to know about agriculture is here'**
  String get agricultureDescription;

  /// Description for searchProducts
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// Description for categories
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Description for seeAll
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Description for noCategoriesAvailable
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// Description for marketNews
  ///
  /// In en, this message translates to:
  /// **'Market News'**
  String get marketNews;

  /// Description for loadingMarketNews
  ///
  /// In en, this message translates to:
  /// **'Loading market news...'**
  String get loadingMarketNews;

  /// Description for failedToLoadMarketNews
  ///
  /// In en, this message translates to:
  /// **'Failed to load market news'**
  String get failedToLoadMarketNews;

  /// Description for noMarketNewsAvailable
  ///
  /// In en, this message translates to:
  /// **'No market news available'**
  String get noMarketNewsAvailable;

  /// Description for tapToRetry
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get tapToRetry;

  /// Description for stayUpdatedMarketNews
  ///
  /// In en, this message translates to:
  /// **'Stay Updated with Market News'**
  String get stayUpdatedMarketNews;

  /// Description for marketNewsDescription
  ///
  /// In en, this message translates to:
  /// **'Get the latest agricultural market trends, prices, and insights to make informed decisions.'**
  String get marketNewsDescription;

  /// Description for exploreNews
  ///
  /// In en, this message translates to:
  /// **'Explore News'**
  String get exploreNews;

  /// Description for featuredProducts
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get featuredProducts;

  /// Description for noFeaturedProductsAvailable
  ///
  /// In en, this message translates to:
  /// **'No featured products available'**
  String get noFeaturedProductsAvailable;

  /// Description for errorLoadingFeaturedProducts
  ///
  /// In en, this message translates to:
  /// **'Error loading featured products: {error}'**
  String errorLoadingFeaturedProducts(String error);

  /// Description for failedToLoadMarketInformation
  ///
  /// In en, this message translates to:
  /// **'Failed to load market information.'**
  String get failedToLoadMarketInformation;

  /// Description for removedFromWishlist
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get removedFromWishlist;

  /// Description for addedToWishlist
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get addedToWishlist;

  /// Description for productAddedToCart
  ///
  /// In en, this message translates to:
  /// **'{productName} added to cart'**
  String productAddedToCart(String productName);

  /// Description for viewCart
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// Description for noCategoriesFound
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @featuredTransports.
  ///
  /// In en, this message translates to:
  /// **'Featured Transports'**
  String get featuredTransports;

  /// No description provided for @noFeaturedTransportsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No featured transports available'**
  String get noFeaturedTransportsAvailable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sw': return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
