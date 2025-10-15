class ApiConfig {
  static const bool isProduction = true; // Set to true for production

  static String get baseUrl {
    return 'https://masokotips.com/api'; // Production URL
  }

  static const Duration timeoutDuration = Duration(seconds: 60);
  static const String apiKey = '';
}
