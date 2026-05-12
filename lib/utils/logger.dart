import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
  level: Level.debug,
);

// Log levels
class Log {
  static void d(dynamic message) => logger.d(message);
  static void i(dynamic message) => logger.i(message);
  static void w(dynamic message) => logger.w(message);
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    String msg = message.toString();
    if (msg.length > 500 && (msg.contains('<html') || msg.contains('<!DOCTYPE'))) {
      msg = '${msg.substring(0, 500)}... [HTML Truncated for readability]';
    }
    logger.e(msg, error: error, stackTrace: stackTrace);
  }
}
