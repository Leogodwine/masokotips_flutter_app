class ApiConfig {
  // Base URL for API requests
  static String get baseUrl {
    return 'https://api.wegazi.com/api';
  }

  // Timeout duration for API requests
  static const Duration timeoutDuration = Duration(seconds: 60);

  // API Keys (if needed)
  static const String apiKey = '';

  // Mock data flag
  static bool useMockData = false;

  // List of alternative base URLs for different environments
  static const List<String> alternativeBaseUrls = [
    'http://10.0.2.2:8000/api', // Android emulator
    'http://localhost:8000/api', // Local development
    'https://api.wegazi.com/api', // Production
  ];

  // Placeholder images
  static const String placeholderImage = 'https://via.placeholder.com/150';
  static const String categoryPlaceholder = 'https://via.placeholder.com/150';
  static const String productPlaceholder = 'https://via.placeholder.com/150';
}
