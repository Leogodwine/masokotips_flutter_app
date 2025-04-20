class ApiConfig {
  /// Toggle this flag to switch between dev and production
  static const bool isProduction = true;

  /// Base URL for API requests
  static String get baseUrl {
    return isProduction
        ? 'https://api.wegazi.com/api'
        : 'http://localhost:8000/api';
  }

  /// Timeout duration for HTTP requests
  static const Duration timeoutDuration = Duration(seconds: 60);

  /// Optional API key (used if required)
  static const String apiKey = '';

  /// Alternative URLs for testing/emulators (not used automatically)
  static const List<String> alternativeBaseUrls = [
    'http://10.0.2.2:8000/api', // Android emulator
    'http://localhost:8000/api', // Local dev
    'https://api.wegazi.com/api', // Production
  ];

  /// Placeholder image URLs
  static const String placeholderImage = 'https://via.placeholder.com/150';
  static const String categoryPlaceholder = 'https://via.placeholder.com/150';
  static const String productPlaceholder = 'https://via.placeholder.com/150';
}
