class AppConstants {
  AppConstants._();

  static const String appName = 'Punto de Venta';

  // Código de barras: hasta este número de dígitos se muestra completo;
  // si tiene más, se muestra en una caja deslizable.
  static const int barcodeInlineMaxDigits = 4;

  // Ancho (dp) por debajo del cual se usa el diseño compacto.
  static const double compactBreakpoint = 720;

  // Límites del ancho de la columna derecha (botones + cobro).
  static const double actionPanelMinWidth = 320;
  static const double actionPanelMaxWidth = 520;
}