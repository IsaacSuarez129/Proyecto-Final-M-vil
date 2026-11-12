// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pvm/app.dart';

void main() {
  testWidgets('Muestra la pantalla principal del POS', (tester) async {
    // Simula una tablet en horizontal.
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PosApp());

    expect(find.text('Botón 1'), findsOneWidget);
    expect(find.text('Cobrar'), findsOneWidget);
  });
}