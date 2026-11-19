import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  // Ejemplo: 1234.5 -> "$1,234.50"
  static String currency(double value) => _currency.format(value);

  // Ejemplo: "19/11/2026 14:35"
  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());
}