import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get statusBarHeight => mediaQuery.padding.top;
  double get bottomBarHeight => mediaQuery.padding.bottom;
  double get safeAreaHeight => screenHeight - statusBarHeight - bottomBarHeight;
}

extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
  String get capitalizeWords =>
      split(' ').map((word) => word.capitalize).join(' ');
  String get trimAndLower => trim().toLowerCase();
  String get trimAndUpper => trim().toUpperCase();
  bool get isEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  bool get isPhone => RegExp(r'^\+?[0-9]{10,}$').hasMatch(this);
  bool get isUrl =>
      RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$').hasMatch(this);
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }
}

extension ColorExtension on Color {
  Color get lighten {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();
  }

  Color get darken {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }
}

extension ExceptionExtension on dynamic {
  String get toFriendlyError {
    if (this == null) return 'An unknown error occurred.';
    final errorLower = toString().toLowerCase();

    // Specific user-facing messages
    if (errorLower.contains('socketexception') ||
        errorLower.contains('connection reset') ||
        errorLower.contains('connection dropped') ||
        errorLower.contains('clientexception')) {
      return 'Connection to server lost. Please try again.';
    }

    if (errorLower.contains('failed host lookup') ||
        errorLower.contains('network') ||
        errorLower.contains('failed to fetch')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (errorLower.contains('404') || errorLower.contains('not found')) {
      return 'The requested information could not be found.';
    }
    
    if (errorLower.contains('500') ||
        errorLower.contains('internal server error')) {
      return 'Our servers are experiencing issues. Please try again later.';
    }
    
    if (errorLower.contains('403') ||
        errorLower.contains('forbidden') ||
        errorLower.contains('unauthorized')) {
      if (errorLower.contains('litespeed') || 
          errorLower.contains('cloudflare') || 
          errorLower.contains('bot') ||
          errorLower.contains('challenge')) {
        return 'Our security system is checking your connection. Please wait a moment and try again.';
      }
      return 'You do not have permission to access this content.';
    }

    if (errorLower.contains('503') || errorLower.contains('service unavailable')) {
      return 'The server is temporarily busy (LiteSpeed). Please try again in a few seconds.';
    }
    
    if (errorLower.contains('format_exception') || errorLower.contains('unexpected character')) {
      return 'The server returned an unexpected response. This might be due to a security check. Please try again.';
    }
    
    if (errorLower.contains('timeout')) {
      return 'The request took too long. Please check your connection and try again.';
    }

    if (errorLower.contains('text/html') || errorLower.contains('unexpected response type')) {
      return 'Our security system is checking your connection. Please wait a moment and try again.';
    }

    String str = toString();
    if (str.startsWith('Exception: ')) {
      str = str.replaceFirst('Exception: ', '');
    }
    
    if (str.length > 100 && !str.contains('<html')) return 'Something went wrong. Please try again.';
    if (str.contains('<html')) return 'The server security system (Bot Protection) interrupted the request. Please try again in a moment.';
    return str;
  }
}
