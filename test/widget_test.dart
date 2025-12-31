// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuelcalc/main.dart';

void main() {
  testWidgets('App starts and shows loading indicator', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FuelCalcApp());

    // Verify that a loading indicator is shown during initialization.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('App creates MaterialApp with correct properties', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FuelCalcApp());

    // Find the MaterialApp
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    // Verify app title
    expect(materialApp.title, equals('Fuel Calculator'));

    // Verify theme is set
    expect(materialApp.theme, isNotNull);
    expect(materialApp.theme?.useMaterial3, isTrue);
  });
}
