import 'dart:convert';

class ApiResponse {
  static bool looksLikeHtml(String body) {
    final lowerBody = body.trimLeft().toLowerCase();
    return lowerBody.startsWith('<!doctype html') ||
        lowerBody.startsWith('<html') ||
        lowerBody.contains('<title>') ||
        lowerBody.contains('</html>');
  }

  static bool looksLikeSecurityChallenge(String body) {
    final lowerBody = body.toLowerCase();
    return looksLikeHtml(body) ||
        lowerBody.contains('litespeed') ||
        lowerBody.contains('recaptcha') ||
        lowerBody.contains('captcha') ||
        lowerBody.contains('bot') ||
        lowerBody.contains('challenge') ||
        lowerBody.contains('verification');
  }

  static dynamic decodeJson(String body) {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) return {};

    if (looksLikeSecurityChallenge(trimmedBody)) {
      throw Exception(
        'Security Check: The server is verifying your request. Please wait a few seconds and try again.',
      );
    }

    try {
      final decoded = jsonDecode(trimmedBody);
      if (decoded == null) return {};
      return decoded;
    } on FormatException {
      throw Exception(
        'The server returned an invalid response. Please try again in a moment.',
      );
    }
  }
}
