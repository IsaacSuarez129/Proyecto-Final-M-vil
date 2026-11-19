import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/features/auth/domain/entities/profile.dart';
import 'package:pvm/features/cash_register/domain/entities/shift.dart';
import 'package:pvm/features/checkout/presentation/screens/pos_home_screen.dart';

void main() {
  testWidgets('Muestra la pantalla principal del POS', (tester) async {
    // Simula una tablet en horizontal.
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    final shift = Shift(
      id: 'test',
      profile: const Profile(id: '1', name: 'Admin', role: ProfileRole.admin),
      openingAmount: 500,
      openedAt: DateTime(2026, 11, 17),
    );

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: PosHomeScreen(shift: shift)),
    );

    expect(find.text('Cajeros'), findsOneWidget);
    expect(find.text('Cobrar'), findsOneWidget);
  });
}