import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/cart/presentation/cart_bottom_sheet.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              onPressed: () {
                unawaited(
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Cart?'),
                      content: const Text('Remove all items?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            unawaited(
                              ref.read(cartProvider.notifier).clearCart(),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: const CartBottomSheet(),
    );
  }
}
