import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('MMM dd, yyyy hh:mm a');

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return _dateFormatter.format(dateTime);
    } catch (_) {
      return dateString;
    }
  }

  static String formatDateTime(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return _dateTimeFormatter.format(dateTime);
    } catch (_) {
      return dateString;
    }
  }
}
