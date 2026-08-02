import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restro_hub/features/explore/presentation/views/unified_explore_screen.dart';
import 'package:restro_hub/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify full ordering flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Splash Screen - Skip to Dashboard (assuming pre-granted permissions or skipping)
      // Since splash is complex, we might just look for the "NEXT" or "GET STARTED" button
      for (var i = 0; i < 3; i++) {
        final nextBtn = find.text('NEXT');
        if (nextBtn.evaluate().isNotEmpty) {
          await tester.tap(nextBtn);
          await tester.pumpAndSettle();
        }
      }

      final getStartedBtn = find.text('GET STARTED');
      if (getStartedBtn.evaluate().isNotEmpty) {
        await tester.tap(getStartedBtn);
        await tester.pumpAndSettle();
      }

      // 2. Dashboard - Navigate to Explore Restaurants
      // Using the key we found earlier
      final exploreBtn = find.byKey(const Key('Explore by Restaurant'));
      await tester.scrollUntilVisible(exploreBtn, 500);
      await tester.tap(exploreBtn);
      await tester.pumpAndSettle();

      expect(find.byType(UnifiedExploreScreen), findsOneWidget);

      // 3. Search for a restaurant (e.g., "RoadSide")
      await tester.enterText(find.byType(TextField), 'RoadSide');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 4. Select the restaurant
      await tester.tap(find.text('RoadSide Cafe'));
      await tester.pumpAndSettle();

      // 5. Add an item to cart (e.g., "Spaghetti")
      final addToCartBtn = find.byIcon(Icons.add).first;
      await tester.tap(addToCartBtn);
      await tester.pumpAndSettle();

      // 6. Go to Cart / Checkout
      await tester.tap(find.byIcon(Icons.shopping_cart_checkout));
      await tester.pumpAndSettle();

      // 7. Place Order
      final placeOrderBtn = find.text('Place Order');
      await tester.tap(placeOrderBtn);
      await tester.pumpAndSettle();

      // 8. Verify we are in the Orders screen
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('ORD'), findsWidgets); // Should find the new order ID
    });
  });
}
