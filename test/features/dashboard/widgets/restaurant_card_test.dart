import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restro_hub/features/dashboard/presentation/widgets/dashboard_cards.dart';

void main() {
  testWidgets('RestaurantCard displays correct name and rating', (
    tester,
  ) async {
    var clicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            name: 'Test Restro',
            index: 0,
            width: 200,
            image: 'assets/food1.webp',
            rating: '4.5',
            onClick: () => clicked = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Restro'), findsOneWidget);
    expect(find.text('4.5 ★'), findsOneWidget);

    await tester.tap(find.byType(GestureDetector));
    expect(clicked, isTrue);
  });
}
