import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/app_image.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/infrastructure/printer/printer_api.g.dart';

class ProcessCheckOut extends ConsumerWidget {
  const ProcessCheckOut({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider).value ?? [];
    final totalAmount = cart.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final checkoutState = ref.watch(checkoutProvider);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    const deliveryCharge = 40.0;
    final discount = checkoutState.discount;
    final finalTotal = totalAmount + deliveryCharge - discount;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Delivery Address
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivery Address',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () {}, child: const Text('Change')),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Home',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '123 Street Name, City, Country',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Order Items
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = cart[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        AppImage(
                          imagePath: item.image,
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'x${item.quantity} • Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: cart.length),
            ),
          ),

          // Bill Summary
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(context, 'Item Total', totalAmount),
                  _buildSummaryRow(context, 'Delivery Fee', deliveryCharge),
                  if (discount > 0)
                    _buildSummaryRow(
                      context,
                      'Voucher Discount',
                      -discount,
                      isDiscount: true,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: colorScheme.outlineVariant),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pay',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rs. ${finalTotal.toStringAsFixed(0)}',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // Process payment logic
            final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
            ref
                .read(ordersProvider.notifier)
                .addOrder(
                  OrderModel(
                    id: orderId,
                    items: cart,
                    totalAmount: finalTotal,
                    subStatus: OrderSubStatus.preparing,
                    timestamp: DateTime.now(),
                    paymentMethod: checkoutState.paymentMethod,
                    discount: discount,
                  ),
                );

            // ── Trigger Native Printer API ──
            unawaited(
              PrinterApi().printReceipt({
                'orderId': orderId,
                'amount': finalTotal.toStringAsFixed(2),
                'itemsCount': cart.length.toString(),
              }),
            );

            unawaited(ref.read(cartProvider.notifier).clearCart());
            context.goNamed('mainDashBoard', extra: {'initialIndex': 2});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Place Order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isDiscount ? "-" : ""}Rs. ${amount.abs().toStringAsFixed(0)}',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
