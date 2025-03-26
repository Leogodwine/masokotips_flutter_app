class ApiConfig {
  // Base URL for API requests
  static String baseUrl = 'http://localhost:8000/api'; // Local WAMP server URL

  // Alternative URLs if the main one fails
  static final List<String> alternativeBaseUrls = [
    'http://10.0.2.2:8000/api', // Android emulator to host localhost
    'http://127.0.0.1:8000/api', // Direct localhost
    'http://localhost:8000/api', // Named localhost
    'http://10.0.3.2:8000/api', // Genymotion emulator to host
  ];

  // Timeout duration for API requests
  static const int timeoutDuration = 60; // seconds

  // API Keys (if needed)
  static const String apiKey = '';

  // Placeholder images
  static const String placeholderImage = 'https://via.placeholder.com/150';
  static const String categoryPlaceholder = 'https://via.placeholder.com/150';
  static const String productPlaceholder = 'https://via.placeholder.com/150';

  // Mock mode - set to true to use mock data rather than real API calls
  static bool useMockData = true;
}
