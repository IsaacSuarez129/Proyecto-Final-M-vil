import 'package:flutter/material.dart';

// Colores propios del punto de venta (fondo, botones y teclado).
class PosColors {
  PosColors._();

  static const Color background = Color(0xFFE9EDF1);

  // Botones de acciones (amarillos).
  static const Color actionButton = Color(0xFFF3E98C);
  static const Color actionButtonBorder = Color(0xFFCFC25E);
  static const Color actionButtonText = Color(0xFF3A3615);

  // Teclas numéricas (crema con número azul).
  static const Color key = Color(0xFFF7F4EA);
  static const Color keyBorder = Color(0xFFD3CEBD);
  static const Color keyText = Color(0xFF1F5FAF);

  // Teclas de utilidad: punto y borrar (gris oscuro).
  static const Color darkKey = Color(0xFF3B4055);
  static const Color darkKeyText = Colors.white;

  // Botón de cobrar (verde).
  static const Color charge = Color(0xFF2ECC71);
  static const Color chargeText = Color(0xFF083B22);

  // Campos Total / Pago / Cambio.
  static const Color fieldLabel = Color(0xFF6B7280);
  static const Color totalText = Color(0xFF1F2937);
  static const Color paymentText = Color(0xFF1F5FAF);
  static const Color changeText = Color(0xFFD32F2F);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00796B));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: PosColors.background,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}