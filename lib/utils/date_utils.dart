import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('MMM dd, yyyy HH:mm').format(date);
}

String formatTime(DateTime date) {
  return DateFormat('HH:mm').format(date);
}

String formatDateWithTime(DateTime date) {
  return DateFormat('MMM dd, yyyy hh:mm a').format(date);
}

String formatDateForApi(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String formatDateTimeForApi(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}
