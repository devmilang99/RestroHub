// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restro_hub/core/providers/preferences_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/router/router_service.dart';
import 'package:restro_hub/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (tester) async {
    // Provide mocked SharedPreferences so providers depending on it work.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Provide a simple GoRouter and mocked SharedPreferences so providers work.
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(),
        ),
      ],
    );

    // Build our app wrapped with ProviderScope and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          goRouterProvider.overrideWithValue(router),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the app builds and a MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
