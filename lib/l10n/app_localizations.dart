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
  /// **'Connect buyers, sellers, transporters & service providers'**
  String get appSubtitle;

  /// No description provided for @membershipPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership Plans'**
  String get membershipPlansTitle;

  /// No description provided for @membershipPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to connect, post listings, and unlock contact details'**
  String get membershipPlansSubtitle;

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
  /// **'maSOKOtips connects buyers, sellers, transporters, and service providers in Tanzania\'s agricultural sector. Discover listings, post buying requests, chat, and build trusted relationships — membership unlocks contact and posting.'**
  String get aboutDescription;

  /// Description for agricultureDescription
  ///
  /// In en, this message translates to:
  /// **'Discover, connect, and grow with Tanzania\'s agricultural community'**
  String get agricultureDescription;

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
  /// **'Enter your country'**
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

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

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

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

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

  /// No description provided for @transportDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transport deleted successfully'**
  String get transportDeletedSuccessfully;

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

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome to maSOKOtips.'**
  String get registrationSuccessful;

  /// No description provided for @selectRoleError.
  ///
  /// In en, this message translates to:
  /// **'Please select a role to register.'**
  String get selectRoleError;

  /// No description provided for @emailTaken.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please try another email or login.'**
  String get emailTaken;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinMasokotips.
  ///
  /// In en, this message translates to:
  /// **'Join maSOKOtips'**
  String get joinMasokotips;

  /// No description provided for @createAccountToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Create an account to get started'**
  String get createAccountToGetStarted;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @usernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, and underscores'**
  String get usernameInvalid;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter your city/region'**
  String get enterLocation;

  /// No description provided for @pleaseEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your location'**
  String get pleaseEnterLocation;

  /// No description provided for @pleaseEnterCountry.
  ///
  /// In en, this message translates to:
  /// **'Please enter your country'**
  String get pleaseEnterCountry;

  /// No description provided for @agentCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Agent / Referral Code (Optional)'**
  String get agentCodeOptional;

  /// No description provided for @agentCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. FA… or RF… — field agent or member code'**
  String get agentCodeHint;

  /// No description provided for @agentCodeHelper.
  ///
  /// In en, this message translates to:
  /// **'If an agent helped you sign up, enter their code here'**
  String get agentCodeHelper;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registerAs.
  ///
  /// In en, this message translates to:
  /// **'Register as...'**
  String get registerAs;

  /// No description provided for @roleBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get roleBuyer;

  /// No description provided for @roleSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get roleSeller;

  /// No description provided for @roleTransporter.
  ///
  /// In en, this message translates to:
  /// **'Transporter'**
  String get roleTransporter;

  /// No description provided for @roleServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get roleServiceProvider;

  /// No description provided for @proofOfIdentity.
  ///
  /// In en, this message translates to:
  /// **'Proof of Identity'**
  String get proofOfIdentity;

  /// No description provided for @optionalText.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalText;

  /// No description provided for @uploadDocumentHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear photo of your NIDA, Driving License, or Voter Card. Your document will be reviewed by our team for account verification. Blurry or incorrect images will delay approval.'**
  String get uploadDocumentHint;

  /// No description provided for @selectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Select document type'**
  String get selectDocumentType;

  /// No description provided for @nidaCard.
  ///
  /// In en, this message translates to:
  /// **'NIDA Card'**
  String get nidaCard;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @voterCard.
  ///
  /// In en, this message translates to:
  /// **'Voter Card'**
  String get voterCard;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @uploadTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Place your ID on a flat surface with good lighting before taking a photo.'**
  String get uploadTip;

  /// No description provided for @createAccountCaps.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccountCaps;

  /// No description provided for @agreeToTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToTermsPrefix;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @agreeToTermsMiddle.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get agreeToTermsMiddle;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms and Conditions and Privacy Policy to register.'**
  String get pleaseAcceptTerms;

  /// No description provided for @featuredServices.
  ///
  /// In en, this message translates to:
  /// **'Featured Services'**
  String get featuredServices;

  /// No description provided for @noFeaturedServicesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No featured services available'**
  String get noFeaturedServicesAvailable;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check Now'**
  String get checkNow;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @subscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required'**
  String get subscriptionRequired;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @foodAndBeverages.
  ///
  /// In en, this message translates to:
  /// **'Food & Beverages'**
  String get foodAndBeverages;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @postServices.
  ///
  /// In en, this message translates to:
  /// **'Post Services'**
  String get postServices;

  /// No description provided for @adminLoginAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLoginAdmin;

  /// No description provided for @accessAdminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Access Admin Dashboard'**
  String get accessAdminDashboard;

  /// No description provided for @cancelAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Cancel and Retry'**
  String get cancelAndRetry;

  /// No description provided for @cancelPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payment'**
  String get cancelPaymentTitle;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @marketDemands.
  ///
  /// In en, this message translates to:
  /// **'Market Demands'**
  String get marketDemands;

  /// No description provided for @agriculturalServices.
  ///
  /// In en, this message translates to:
  /// **'Agricultural Services'**
  String get agriculturalServices;

  /// No description provided for @cancelCaps.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelCaps;

  /// No description provided for @subscribeNowCaps.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIBE NOW'**
  String get subscribeNowCaps;

  /// No description provided for @phoneNumberNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNumberNotAvailable;

  /// No description provided for @couldNotLaunchDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch dialer'**
  String get couldNotLaunchDialer;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @settingsAndAbout.
  ///
  /// In en, this message translates to:
  /// **'Settings & About'**
  String get settingsAndAbout;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @appTitleSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appTitleSection;

  /// No description provided for @appNameLabel.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appNameLabel;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @seeStoreListingForLatest.
  ///
  /// In en, this message translates to:
  /// **'See store listing for latest'**
  String get seeStoreListingForLatest;

  /// No description provided for @accountDeletionRequestSubject.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion Request - maSOKOtips'**
  String get accountDeletionRequestSubject;

  /// No description provided for @accountDeletionRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Hello maSOKOtips Team,\n\nI would like to request deletion of my account and associated data.\n\nPlease confirm once completed.\n\nThanks.'**
  String get accountDeletionRequestBody;

  /// No description provided for @noEmailAppFound.
  ///
  /// In en, this message translates to:
  /// **'No email app found to send request'**
  String get noEmailAppFound;

  /// No description provided for @helloGuest.
  ///
  /// In en, this message translates to:
  /// **'Hello Guest'**
  String get helloGuest;

  /// No description provided for @signInToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToYourAccount;

  /// No description provided for @homeMenu.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeMenu;

  /// No description provided for @productsMenu.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsMenu;

  /// No description provided for @transportMenu.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transportMenu;

  /// No description provided for @marketInfoMenu.
  ///
  /// In en, this message translates to:
  /// **'Market Info'**
  String get marketInfoMenu;

  /// No description provided for @profileMenu.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileMenu;

  /// No description provided for @myOrdersMenu.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrdersMenu;

  /// No description provided for @wishlistMenu.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistMenu;

  /// No description provided for @settingsMenu.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenu;

  /// No description provided for @privacyPolicyMenu.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyMenu;

  /// No description provided for @helpAndSupportMenu.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupportMenu;

  /// No description provided for @aboutMenu.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutMenu;

  /// No description provided for @logoutMenu.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutMenu;

  /// No description provided for @aboutMasokoTips.
  ///
  /// In en, this message translates to:
  /// **'About maSOKO tips'**
  String get aboutMasokoTips;

  /// No description provided for @aboutMasokoTipsDescription.
  ///
  /// In en, this message translates to:
  /// **'maSOKO tips is your agricultural marketplace companion. Find products, services, and market information all in one place.'**
  String get aboutMasokoTipsDescription;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @twofactorAuthenticationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication enabled'**
  String get twofactorAuthenticationEnabled;

  /// No description provided for @viewOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'View Order History'**
  String get viewOrderHistory;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @thisActionCannotBeUndoneAll.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get thisActionCannotBeUndoneAll;

  /// No description provided for @pleaseLoginToSendAMessage.
  ///
  /// In en, this message translates to:
  /// **'Please login to send a message.'**
  String get pleaseLoginToSendAMessage;

  /// No description provided for @pleaseLoginToAddATransport.
  ///
  /// In en, this message translates to:
  /// **'Please login to add a transport'**
  String get pleaseLoginToAddATransport;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get startYourJourney;

  /// No description provided for @newsCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'News copied to clipboard'**
  String get newsCopiedToClipboard;

  /// No description provided for @addFoodBeverage.
  ///
  /// In en, this message translates to:
  /// **'Add Food & Beverage'**
  String get addFoodBeverage;

  /// No description provided for @addNewTransport.
  ///
  /// In en, this message translates to:
  /// **'Add New Transport'**
  String get addNewTransport;

  /// No description provided for @orderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmation'**
  String get orderConfirmation;

  /// No description provided for @deleteAlt.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteAlt;

  /// No description provided for @noServicesFound.
  ///
  /// In en, this message translates to:
  /// **'No services found'**
  String get noServicesFound;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @noDashboardDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No dashboard data available'**
  String get noDashboardDataAvailable;

  /// No description provided for @onlyAdministratorsCanEditMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Only administrators can edit market information'**
  String get onlyAdministratorsCanEditMarketInformation;

  /// No description provided for @deleteService.
  ///
  /// In en, this message translates to:
  /// **'Delete Service'**
  String get deleteService;

  /// No description provided for @clearWishlist.
  ///
  /// In en, this message translates to:
  /// **'Clear Wishlist'**
  String get clearWishlist;

  /// No description provided for @adminLoginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Admin login successful!'**
  String get adminLoginSuccessful;

  /// No description provided for @undoRemove.
  ///
  /// In en, this message translates to:
  /// **'Undo Remove'**
  String get undoRemove;

  /// No description provided for @viewYourAccountActivity.
  ///
  /// In en, this message translates to:
  /// **'View your account activity'**
  String get viewYourAccountActivity;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @pleaseSelectACategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectACategory;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @pleaseLogInToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view profile'**
  String get pleaseLogInToViewProfile;

  /// No description provided for @suspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get suspend;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello!'**
  String get sayHello;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @pleaseLoginAsAdminToAccess.
  ///
  /// In en, this message translates to:
  /// **'Please login as admin to access organic products'**
  String get pleaseLoginAsAdminToAccess;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity Log'**
  String get activityLog;

  /// No description provided for @pleaseLoginToAddMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Please login to add market information'**
  String get pleaseLoginToAddMarketInformation;

  /// No description provided for @okChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'OK, Change Number'**
  String get okChangeNumber;

  /// No description provided for @adminAccountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Admin account created successfully!'**
  String get adminAccountCreatedSuccessfully;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @cancelPayment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payment'**
  String get cancelPayment;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @youDoNotHavePermissionTo.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this feature.'**
  String get youDoNotHavePermissionTo;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @bookTransportService.
  ///
  /// In en, this message translates to:
  /// **'Book Transport Service'**
  String get bookTransportService;

  /// No description provided for @pleaseAddAtLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one product image'**
  String get pleaseAddAtLeastOneProduct;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @twofactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twofactorAuthentication;

  /// No description provided for @unsuspendUser.
  ///
  /// In en, this message translates to:
  /// **'Unsuspend User'**
  String get unsuspendUser;

  /// No description provided for @onlyAdministratorsCanAddMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Only administrators can add market information'**
  String get onlyAdministratorsCanAddMarketInformation;

  /// No description provided for @marketInformationManagement.
  ///
  /// In en, this message translates to:
  /// **'Market Information Management'**
  String get marketInformationManagement;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @organicProductCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Organic product created successfully!'**
  String get organicProductCreatedSuccessfully;

  /// No description provided for @vehicleIsInsuredForCargoAnd.
  ///
  /// In en, this message translates to:
  /// **'Vehicle is insured for cargo and liability'**
  String get vehicleIsInsuredForCargoAnd;

  /// No description provided for @itemUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item updated successfully!'**
  String get itemUpdatedSuccessfully;

  /// No description provided for @organicProductUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Organic product updated successfully!'**
  String get organicProductUpdatedSuccessfully;

  /// No description provided for @unsuspendingUser.
  ///
  /// In en, this message translates to:
  /// **'Unsuspending user...'**
  String get unsuspendingUser;

  /// No description provided for @youCannotChatWithYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot chat with yourself.'**
  String get youCannotChatWithYourself;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick Image'**
  String get pickImage;

  /// No description provided for @transportServiceUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transport service updated successfully!'**
  String get transportServiceUpdatedSuccessfully;

  /// No description provided for @failedToCreateAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to create admin account'**
  String get failedToCreateAdminAccount;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @pleaseLoginToCall.
  ///
  /// In en, this message translates to:
  /// **'Please login to call.'**
  String get pleaseLoginToCall;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @receiveUpdatesAndAlertsViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Receive updates and alerts via email'**
  String get receiveUpdatesAndAlertsViaEmail;

  /// No description provided for @noReviewsPendingModeration.
  ///
  /// In en, this message translates to:
  /// **'No reviews pending moderation'**
  String get noReviewsPendingModeration;

  /// No description provided for @postRequest.
  ///
  /// In en, this message translates to:
  /// **'Post Request'**
  String get postRequest;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccessfully;

  /// No description provided for @providerContactInfoIsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Provider contact info is not available. Please call instead.'**
  String get providerContactInfoIsNotAvailable;

  /// No description provided for @cancelAlt.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelAlt;

  /// No description provided for @suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// No description provided for @areYouSureYouWantTo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this market information?'**
  String get areYouSureYouWantTo;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get price;

  /// No description provided for @activityLogFeatureIsUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Activity log feature is under development'**
  String get activityLogFeatureIsUnderDevelopment;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @suspendingUser.
  ///
  /// In en, this message translates to:
  /// **'Suspending user...'**
  String get suspendingUser;

  /// No description provided for @receiveAVerificationCodeWhenSigning.
  ///
  /// In en, this message translates to:
  /// **'Receive a verification code when signing in'**
  String get receiveAVerificationCodeWhenSigning;

  /// No description provided for @postBuyingRequest.
  ///
  /// In en, this message translates to:
  /// **'Post Buying Request'**
  String get postBuyingRequest;

  /// No description provided for @serviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Service Management'**
  String get serviceManagement;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date ↑'**
  String get date;

  /// No description provided for @showThisItemInFeaturedSection.
  ///
  /// In en, this message translates to:
  /// **'Show this item in featured section'**
  String get showThisItemInFeaturedSection;

  /// No description provided for @deleteRequest.
  ///
  /// In en, this message translates to:
  /// **'Delete Request'**
  String get deleteRequest;

  /// No description provided for @createAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Admin Account'**
  String get createAdminAccount;

  /// No description provided for @couldNotLaunchPhoneDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer.'**
  String get couldNotLaunchPhoneDialer;

  /// No description provided for @goBackWithoutCompletingPayment.
  ///
  /// In en, this message translates to:
  /// **'Go back without completing payment?'**
  String get goBackWithoutCompletingPayment;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @areYouSureYouWantToAlt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product? This action cannot be undone.'**
  String get areYouSureYouWantToAlt;

  /// No description provided for @pleaseLoginToEditYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Please login to edit your profile'**
  String get pleaseLoginToEditYourProfile;

  /// No description provided for @temperatureControlled.
  ///
  /// In en, this message translates to:
  /// **'Temperature Controlled'**
  String get temperatureControlled;

  /// No description provided for @noMapsAppFoundOnThis.
  ///
  /// In en, this message translates to:
  /// **'No maps app found on this device.'**
  String get noMapsAppFoundOnThis;

  /// No description provided for @organicProductDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Organic product deleted successfully'**
  String get organicProductDeletedSuccessfully;

  /// No description provided for @makeThisItemVisibleToCustomers.
  ///
  /// In en, this message translates to:
  /// **'Make this item visible to customers'**
  String get makeThisItemVisibleToCustomers;

  /// No description provided for @enterPaymentNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Payment Number'**
  String get enterPaymentNumber;

  /// No description provided for @myWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// No description provided for @logoutAlt.
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logoutAlt;

  /// No description provided for @deviceManagementFeatureIsUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Device management feature is under development'**
  String get deviceManagementFeatureIsUnderDevelopment;

  /// No description provided for @makeProductVisibleToCustomers.
  ///
  /// In en, this message translates to:
  /// **'Make product visible to customers'**
  String get makeProductVisibleToCustomers;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @goToMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Go to Market Information'**
  String get goToMarketInformation;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @resetLinkSentToYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to your email'**
  String get resetLinkSentToYourEmail;

  /// No description provided for @addMarketNews.
  ///
  /// In en, this message translates to:
  /// **'Add Market News'**
  String get addMarketNews;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'SEND RESET LINK'**
  String get sendResetLink;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @requestDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Request deleted successfully'**
  String get requestDeletedSuccessfully;

  /// No description provided for @searchServices.
  ///
  /// In en, this message translates to:
  /// **'Search Services'**
  String get searchServices;

  /// No description provided for @areYouSureYouWantToAltAlt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your wishlist?'**
  String get areYouSureYouWantToAltAlt;

  /// No description provided for @showThisProductInFeaturedSection.
  ///
  /// In en, this message translates to:
  /// **'Show this product in featured section'**
  String get showThisProductInFeaturedSection;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @productCategoryNotFoundInCurrent.
  ///
  /// In en, this message translates to:
  /// **'Product category not found in current categories. Please select a category.'**
  String get productCategoryNotFoundInCurrent;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLogin;

  /// No description provided for @bookmarkFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Bookmark feature coming soon!'**
  String get bookmarkFeatureComingSoon;

  /// No description provided for @serviceAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Service added to cart'**
  String get serviceAddedToCart;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @paymentConfirmedSubscriptionIsNowActive.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed! Subscription is now active.'**
  String get paymentConfirmedSubscriptionIsNowActive;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'START SHOPPING'**
  String get startShopping;

  /// No description provided for @makeThisProductVisibleToCustomers.
  ///
  /// In en, this message translates to:
  /// **'Make this product visible to customers'**
  String get makeThisProductVisibleToCustomers;

  /// No description provided for @myFoodBeverages.
  ///
  /// In en, this message translates to:
  /// **'My Food & Beverages'**
  String get myFoodBeverages;

  /// No description provided for @pleaseSelectAPlan.
  ///
  /// In en, this message translates to:
  /// **'Please select a plan'**
  String get pleaseSelectAPlan;

  /// No description provided for @loginAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Login as Admin'**
  String get loginAsAdmin;

  /// No description provided for @keepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep Order'**
  String get keepOrder;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @productCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get productCreatedSuccessfully;

  /// No description provided for @editOrganicProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Organic Product'**
  String get editOrganicProduct;

  /// No description provided for @pleaseLoginToEditMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Please login to edit market information'**
  String get pleaseLoginToEditMarketInformation;

  /// No description provided for @transportServiceAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transport service added successfully!'**
  String get transportServiceAddedSuccessfully;

  /// No description provided for @checkStatus.
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get checkStatus;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment'**
  String get processingPayment;

  /// No description provided for @addTransportService.
  ///
  /// In en, this message translates to:
  /// **'Add Transport Service'**
  String get addTransportService;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessagesYet;

  /// No description provided for @signUpNow.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Now'**
  String get signUpNow;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @selectOrganicCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Organic Category'**
  String get selectOrganicCategory;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @browseFirst.
  ///
  /// In en, this message translates to:
  /// **'Browse First'**
  String get browseFirst;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @agentDashboard.
  ///
  /// In en, this message translates to:
  /// **'Agent Dashboard'**
  String get agentDashboard;

  /// No description provided for @editFoodBeverage.
  ///
  /// In en, this message translates to:
  /// **'Edit Food & Beverage'**
  String get editFoodBeverage;

  /// No description provided for @cancelPaymentAlt.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payment?'**
  String get cancelPaymentAlt;

  /// No description provided for @hasInsurance.
  ///
  /// In en, this message translates to:
  /// **'Has Insurance'**
  String get hasInsurance;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @areYouSureYouWantToAltAltAlt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureYouWantToAltAltAlt;

  /// No description provided for @accountDeletionFeatureIsUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Account deletion feature is under development'**
  String get accountDeletionFeatureIsUnderDevelopment;

  /// No description provided for @transportCategories.
  ///
  /// In en, this message translates to:
  /// **'Transport Categories'**
  String get transportCategories;

  /// No description provided for @editMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit Market Information'**
  String get editMarketInformation;

  /// No description provided for @receiveUpdatesAndAlertsViaSms.
  ///
  /// In en, this message translates to:
  /// **'Receive updates and alerts via SMS'**
  String get receiveUpdatesAndAlertsViaSms;

  /// No description provided for @organicProductsManagement.
  ///
  /// In en, this message translates to:
  /// **'Organic Products Management'**
  String get organicProductsManagement;

  /// No description provided for @showProductInFeaturedSection.
  ///
  /// In en, this message translates to:
  /// **'Show product in featured section'**
  String get showProductInFeaturedSection;

  /// No description provided for @orderCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully'**
  String get orderCancelledSuccessfully;

  /// No description provided for @foodBeverageItemCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Food & Beverage item created successfully!'**
  String get foodBeverageItemCreatedSuccessfully;

  /// No description provided for @addAService.
  ///
  /// In en, this message translates to:
  /// **'Add a Service'**
  String get addAService;

  /// No description provided for @updatingUser.
  ///
  /// In en, this message translates to:
  /// **'Updating user...'**
  String get updatingUser;

  /// No description provided for @masokotips.
  ///
  /// In en, this message translates to:
  /// **'maSOKOtips'**
  String get masokotips;

  /// No description provided for @noRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'No recent searches'**
  String get noRecentSearches;

  /// No description provided for @vehicleHasTemperatureControlForSensitive.
  ///
  /// In en, this message translates to:
  /// **'Vehicle has temperature control for sensitive products'**
  String get vehicleHasTemperatureControlForSensitive;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @stillPendingPleaseApproveOnYour.
  ///
  /// In en, this message translates to:
  /// **'Still pending — please approve on your phone.'**
  String get stillPendingPleaseApproveOnYour;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check Again'**
  String get checkAgain;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reviewStatistics.
  ///
  /// In en, this message translates to:
  /// **'Review Statistics'**
  String get reviewStatistics;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card Payment'**
  String get cardPayment;

  /// No description provided for @deletingUser.
  ///
  /// In en, this message translates to:
  /// **'Deleting user...'**
  String get deletingUser;

  /// No description provided for @areYouSureYouWantToAltAltAltAlt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get areYouSureYouWantToAltAltAltAlt;

  /// No description provided for @editTransport.
  ///
  /// In en, this message translates to:
  /// **'Edit Transport'**
  String get editTransport;

  /// No description provided for @areYouSureYouWantToAltAltAltAltAlt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get areYouSureYouWantToAltAltAltAltAlt;

  /// No description provided for @suspendUser.
  ///
  /// In en, this message translates to:
  /// **'Suspend User'**
  String get suspendUser;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// No description provided for @pleaseEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services'**
  String get pleaseEnableLocationServices;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccount;

  /// No description provided for @transportManagement.
  ///
  /// In en, this message translates to:
  /// **'Transport Management'**
  String get transportManagement;

  /// No description provided for @servicesManagement.
  ///
  /// In en, this message translates to:
  /// **'Services Management'**
  String get servicesManagement;

  /// No description provided for @locationServicesAreDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesAreDisabled;

  /// No description provided for @unsuspend.
  ///
  /// In en, this message translates to:
  /// **'Unsuspend'**
  String get unsuspend;

  /// No description provided for @reviewModeration.
  ///
  /// In en, this message translates to:
  /// **'Review Moderation'**
  String get reviewModeration;

  /// No description provided for @thisWillCancelThePendingPayment.
  ///
  /// In en, this message translates to:
  /// **'This will cancel the pending payment so you can try again with a new payment request.'**
  String get thisWillCancelThePendingPayment;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @keepWaiting.
  ///
  /// In en, this message translates to:
  /// **'Keep Waiting'**
  String get keepWaiting;

  /// No description provided for @priceAlt.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get priceAlt;

  /// No description provided for @marketInformationDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Market information deleted successfully'**
  String get marketInformationDeletedSuccessfully;

  /// No description provided for @pleaseEnterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterYourEmailAddress;

  /// No description provided for @manageDevicesThatAreLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Manage devices that are logged in'**
  String get manageDevicesThatAreLoggedIn;

  /// No description provided for @postARequest.
  ///
  /// In en, this message translates to:
  /// **'Post a Request'**
  String get postARequest;

  /// No description provided for @subscribeNowAlt.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIBE NOW'**
  String get subscribeNowAlt;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @thisTruckDoesNotHaveA.
  ///
  /// In en, this message translates to:
  /// **'This truck does not have a GPS location set.'**
  String get thisTruckDoesNotHaveA;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @thisAddressWillBeSelectedBy.
  ///
  /// In en, this message translates to:
  /// **'This address will be selected by default during checkout'**
  String get thisAddressWillBeSelectedBy;

  /// No description provided for @paymentStillPendingPleaseApproveOn.
  ///
  /// In en, this message translates to:
  /// **'Payment still pending. Please approve on your phone or cancel to retry.'**
  String get paymentStillPendingPleaseApproveOn;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'Total Reviews'**
  String get totalReviews;

  /// No description provided for @deleteMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Delete Market Information'**
  String get deleteMarketInformation;

  /// No description provided for @retryAlt.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retryAlt;

  /// No description provided for @twofactorAuthenticationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication disabled'**
  String get twofactorAuthenticationDisabled;

  /// No description provided for @kiswahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get kiswahili;

  /// No description provided for @filterReviews.
  ///
  /// In en, this message translates to:
  /// **'Filter Reviews'**
  String get filterReviews;

  /// No description provided for @cancelPaymentAltAlt.
  ///
  /// In en, this message translates to:
  /// **'Cancel payment'**
  String get cancelPaymentAltAlt;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name ↑'**
  String get name;

  /// No description provided for @subscribeToViewContactChat.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to view contact & chat'**
  String get subscribeToViewContactChat;

  /// No description provided for @productsManagement.
  ///
  /// In en, this message translates to:
  /// **'Products Management'**
  String get productsManagement;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @adminSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Admin settings coming soon!'**
  String get adminSettingsComingSoon;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @requestPostedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Request posted successfully!'**
  String get requestPostedSuccessfully;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @pleaseSelectAtLeastOneSupported.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one supported product type'**
  String get pleaseSelectAtLeastOneSupported;

  /// No description provided for @referralCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied!'**
  String get referralCodeCopied;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @yourSubscriptionIsNowActive.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is now active.'**
  String get yourSubscriptionIsNowActive;

  /// No description provided for @onlyGifPngJpgAndJpeg.
  ///
  /// In en, this message translates to:
  /// **'Only .gif, .png, .jpg, and .jpeg files are allowed'**
  String get onlyGifPngJpgAndJpeg;

  /// No description provided for @deleteTransport.
  ///
  /// In en, this message translates to:
  /// **'Delete Transport'**
  String get deleteTransport;

  /// No description provided for @nameAlt.
  ///
  /// In en, this message translates to:
  /// **'Name ↓'**
  String get nameAlt;

  /// No description provided for @locationPermissionPermanentlyDeniedEnableIn.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied. Enable in settings.'**
  String get locationPermissionPermanentlyDeniedEnableIn;

  /// No description provided for @addMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Add Market Information'**
  String get addMarketInformation;

  /// No description provided for @deleteFoodBeverage.
  ///
  /// In en, this message translates to:
  /// **'Delete Food & Beverage'**
  String get deleteFoodBeverage;

  /// No description provided for @updateMarketInformation.
  ///
  /// In en, this message translates to:
  /// **'Update Market Information'**
  String get updateMarketInformation;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @myBuyingRequests.
  ///
  /// In en, this message translates to:
  /// **'My Buying Requests'**
  String get myBuyingRequests;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;
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
