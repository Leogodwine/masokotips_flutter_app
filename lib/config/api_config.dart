import 'package:flutter/foundation.dart';
import 'dev_config.dart'; // 👈 Import it

class ApiConfig {
  static const bool isProduction = false; // Set to true for production

  static String get baseUrl {
    if (isProduction) {
      return 'https://api.wegazi.com/api';
    } else {
      if (kIsWeb) {
        return 'http://localhost:8000/api'; // Web still uses localhost
      } else {
        // Devices and emulators use ngrok URL during development
        return '${DevConfig.ngrokUrl}/api';
      }
    }
  }

  static const Duration timeoutDuration = Duration(seconds: 60);
  static const String apiKey = '';
}
