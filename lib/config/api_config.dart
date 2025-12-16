class ApiConfig {
  // Set to true for production, false for development
  static const bool isProduction = true; // Changed to false for development

  static const String baseUrl = isProduction
      ? 'https://masokotips.com/api' // Production URL
      : 'http://localhost:8000/api'; // Development URL

  static const Duration timeoutDuration = Duration(seconds: 60);
  static const String apiKey = '';

  // Diagnostic info (print statements removed for lint compliance)
  static void printConfig() {
    // Configuration debug info - removed print statements
  }
}
