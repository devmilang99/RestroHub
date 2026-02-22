import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';

class ReceiptDialog extends ConsumerWidget {
  final List<CartModel> items;
  final double total;
  final String? voucherCode;

  const ReceiptDialog({
    super.key,
    required this.items,
    required this.total,
    this.voucherCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.colorScheme;
    final textTheme = context.textTheme;
    final discount = _calculateDiscount(total, voucherCode);
    final finalTotal = (total - discount).clamp(0.0, double.infinity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with background image
              Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cs.primary, cs.primary.withValues(alpha: .7)],
                      ),
                    ),
                    child: Image.asset('assets/food4.webp', fit: BoxFit.cover),
                  ),
                  // Overlay for readability
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .3),
                          Colors.black.withValues(alpha: .5),
                        ],
                      ),
                    ),
                  ),
                  // Header content
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Order Confirmed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Order Receipt',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
              // Content section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: cs.surface),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Items list
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (context, index) {
                          final it = items[index];
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  it.image,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.name,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${it.quantity} x Rs. ${it.price.toStringAsFixed(0)}',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rs. ${(it.price * (it.quantity)).toStringAsFixed(0)}',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                    if (voucherCode != null && voucherCode!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_num_outlined,
                            color: cs.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Voucher: $voucherCode',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          if (discount > 0)
                            Text(
                              '- Rs. ${discount.toStringAsFixed(0)}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    const Divider(),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: textTheme.bodyLarge),
                        Text(
                          'Rs. ${total.toStringAsFixed(0)}',
                          style: textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount', style: textTheme.bodyLarge),
                        Text(
                          '- Rs. ${discount.toStringAsFixed(0)}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs. ${finalTotal.toStringAsFixed(0)}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: cs.onSurface.withValues(alpha: .12),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close', style: textTheme.bodyLarge),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              try {
                                context.pop();
                              } catch (_) {}
                              ref.read(cartProvider.notifier).clearCart();
                              context.push('/processCheckout');
                            },
                            child: Text(
                              'Confirm & Checkout',
                              style: textTheme.bodyLarge?.copyWith(
                                color: cs.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDiscount(double total, String? voucher) {
    if (voucher == null || voucher.isEmpty) return 0.0;
    // Mock logic: if voucher is like SAVE10 => 10% discount, SAVE50 => flat 50
    if (voucher.toUpperCase().startsWith('SAVE')) {
      final numPart = voucher.replaceAll(RegExp('[^0-9]'), '');
      if (numPart.isNotEmpty) {
        final v = double.tryParse(numPart) ?? 0.0;
        if (v <= 100) {
          // treat as percent
          return total * (v / 100.0);
        }
        return v;
      }
    }
    return 0.0;
  }
}
