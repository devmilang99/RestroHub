import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/app_image.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/checkout/presentation/providers/checkout_provider.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  final TextEditingController _voucherController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _appliedVoucher;
  bool _isScrolling = false;

  @override
  void dispose() {
    _voucherController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openVoucherSelection(BuildContext context) {
    final vouchers = [
      {'code': 'SAVE10', 'label': 'Save 10% on your order'},
      {'code': 'FLAT50', 'label': 'Flat Rs. 50 off'},
      {'code': 'SAVE20', 'label': 'Save 20% on orders above Rs.500'},
    ];
    final cs = context.colorScheme;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.local_offer_outlined, color: cs.primary),
              const SizedBox(width: 12),
              const Text('Available Vouchers'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(vouchers.length, (index) {
                final v = vouchers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _appliedVoucher = v['code'];
                        _voucherController.text = _appliedVoucher!;
                      });
                      ref
                          .read(checkoutProvider.notifier)
                          .setVoucher(
                            _appliedVoucher,
                            index == 1 ? 50.0 : 20.0, // Mock discount values
                          );
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Voucher "${v['code']}" applied'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v['code']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  v['label']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle_outline,
                            color: cs.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider).value ?? [];
    final cartNotifier = ref.read(cartProvider.notifier);
    final colorScheme = context.colorScheme;

    if (cartItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add some delicious items to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    setState(() => _isScrolling = true);
                  } else if (notification is ScrollEndNotification) {
                    setState(() => _isScrolling = false);
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppImage(
                            imagePath: item.image,
                            width: 54,
                            height: 54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rs. ${item.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Premium Quantity Control
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: Icon(
                                    item.quantity > 1
                                        ? Icons.remove
                                        : Icons.delete_outline,
                                    size: 16,
                                    color: item.quantity > 1
                                        ? colorScheme.onSurfaceVariant
                                        : Colors.red,
                                  ),
                                  onPressed: () => unawaited(
                                    cartNotifier.updateQuantity(
                                      item.id ?? item.name,
                                      item.quantity - 1,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  icon: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  onPressed: () => unawaited(
                                    cartNotifier.updateQuantity(
                                      item.id ?? item.name,
                                      item.quantity + 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Premium Condensed Checkout Card with Scroll-Aware Visibility
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isScrolling ? 0.0 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isScrolling ? 0 : null,
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: .3,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: .5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 1. Voucher & Payment Control Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Compact Voucher Control
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 6,
                                    ),
                                    child: Text(
                                      'Voucher',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: colorScheme.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: _appliedVoucher == null
                                        ? GestureDetector(
                                            onTap: () =>
                                                _openVoucherSelection(context),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withValues(alpha: .05),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: colorScheme.primary
                                                      .withValues(alpha: .1),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.local_offer_outlined,
                                                    size: 16,
                                                    color: colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Add Voucher',
                                                    style: TextStyle(
                                                      color:
                                                          colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(
                                                alpha: .1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  size: 14,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _appliedVoucher!,
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(
                                                      () => _appliedVoucher =
                                                          null,
                                                    );
                                                    ref
                                                        .read(
                                                          checkoutProvider
                                                              .notifier,
                                                        )
                                                        .setVoucher(null, 0);
                                                  },
                                                  child: const Icon(
                                                    Icons.delete,
                                                    size: 26,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Compact Payment Toggle
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    ref.watch(checkoutProvider).paymentMethod ==
                                            PaymentMethod.qr
                                        ? 'QR Pay'
                                        : 'Cash',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: .5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _CompactPaymentOption(
                                        isSelected:
                                            ref
                                                .watch(checkoutProvider)
                                                .paymentMethod ==
                                            PaymentMethod.cod,
                                        icon: Icons.money,
                                        onTap: () => ref
                                            .read(checkoutProvider.notifier)
                                            .setPaymentMethod(
                                              PaymentMethod.cod,
                                            ),
                                      ),
                                      _CompactPaymentOption(
                                        isSelected:
                                            ref
                                                .watch(checkoutProvider)
                                                .paymentMethod ==
                                            PaymentMethod.qr,
                                        icon: Icons.qr_code_scanner,
                                        onTap: () => ref
                                            .read(checkoutProvider.notifier)
                                            .setPaymentMethod(PaymentMethod.qr),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        // 2. Condensed Summary Rows
                        _buildCompactSummaryRow(
                          'Subtotal',
                          'Rs. ${ref.watch(cartTotalAmountProvider).toStringAsFixed(0)}',
                          colorScheme,
                        ),
                        const SizedBox(height: 6),
                        _buildCompactSummaryRow(
                          'Delivery Fee',
                          'Rs. 40',
                          colorScheme,
                        ),
                        if (_appliedVoucher != null) ...[
                          const SizedBox(height: 6),
                          _buildCompactSummaryRow(
                            'Discount',
                            '- Rs. 50',
                            colorScheme,
                            isHighlight: true,
                          ),
                        ],
                        const SizedBox(height: 12),
                        // 3. Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Rs. ${(ref.watch(cartTotalAmountProvider) + 40 - (_appliedVoucher != null ? 50 : 0)).toStringAsFixed(0)}',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet first
                  unawaited(context.push('/processCheckout'));
                },
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSummaryRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: .5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? Colors.green : colorScheme.onSurface,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CompactPaymentOption extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _CompactPaymentOption({
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurface.withValues(alpha: .4),
        ),
      ),
    );
  }
}
