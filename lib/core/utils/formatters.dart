import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency =
      NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  // Ejemplo: 1234.5 -> "$1,234.50"
  static String currency(double value) => _currency.format(value);
}
