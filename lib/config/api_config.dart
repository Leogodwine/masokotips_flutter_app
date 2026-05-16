import 'package:flutter/foundation.dart';

class ApiConfig {
  // Set to true for production, false for development
  static const bool isProduction = true; // Back to production for live testing

  static const String baseUrl = isProduction
      ? 'https://masokotips.com/api' // Production URL
      : 'https://masokotips.com/api'; // Development URL

  static const Duration timeoutDuration = Duration(seconds: 60);
  static const String apiKey = '';

  // Diagnostic info (print statements removed for lint compliance)
  static void printConfig() {
    // Configuration debug info - removed print statements
  }

  /// Get standard headers for API requests to bypass bot detection
  static Map<String, String> getHeaders([String? token]) {
    final Map<String, String> h = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }

    if (kIsWeb) {
      // Browser environment: Keep headers minimal to avoid CORS preflight issues
      // Browsers handle User-Agent, Origin, and Referer automatically.
      h['X-Requested-With'] = 'XMLHttpRequest';
    } else {
      // Mobile/Native environment: Use aggressive headers to bypass bot detection (LiteSpeed/WAF)
      h['X-Requested-With'] = 'XMLHttpRequest';
      h['Referer'] = 'https://masokotips.com/';
      h['Origin'] = 'https://masokotips.com/';
      h['X-App-Identifier'] = 'MasokoTips-Flutter-App';
      h['Accept-Language'] = 'en-US,en;q=0.9';
      
      // These headers help mimic a real browser request signature on mobile
      h['User-Agent'] =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';
      
      // Security/Fetch headers (Safe to send from native apps, may cause CORS issues on Web)
      h['Sec-Fetch-Mode'] = 'cors';
      h['Sec-Fetch-Site'] = 'same-origin';
      h['Sec-Fetch-Dest'] = 'empty';
    }

    return h;
  }
}
