import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';

Future<void> showReorderDialog(
  BuildContext context,
  WidgetRef ref,
  OrderModel order,
) async {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Order Again?'),
      content: const Text(
        'Proceeding will replace your current cart with these items and take you to checkout.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final cartNotifier = ref.read(cartProvider.notifier);
            unawaited(cartNotifier.clearCart());
            for (final item in order.items) {
              unawaited(
                cartNotifier.addItem(item),
              );
            }
            Navigator.pop(context);
            unawaited(context.pushNamed('processCheckout'));
          },
          child: const Text('Proceed'),
        ),
      ],
    ),
  );
}
