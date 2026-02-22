import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/widgets/receipt_dialog.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  final TextEditingController _voucherController = TextEditingController();
  String? _appliedVoucher;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(BuildContext context, WidgetRef ref) {
    // Show the glassmorphic receipt dialog with ordered items and voucher
    final items = ref.read(cartProvider);
    final totalAmount = ref.read(cartTotalAmountProvider);
    showDialog(
      context: context,
      builder: (context) => ReceiptDialog(
        items: items,
        total: totalAmount,
        voucherCode: _appliedVoucher ?? _voucherController.text,
      ),
    );
  }

  void _openVoucherSelection(BuildContext context) {
    final vouchers = [
      {'code': 'SAVE10', 'label': 'Save 10% on your order'},
      {'code': 'FLAT50', 'label': 'Flat Rs. 50 off'},
      {'code': 'SAVE20', 'label': 'Save 20% on orders above Rs.500'},
    ];
    final cs = context.colorScheme;

    showDialog(
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _appliedVoucher = v['code'] as String;
                      _voucherController.text = _appliedVoucher!;
                    });
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
                      color: cs.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.primary.withOpacity(0.2)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    if (cartItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              "Your cart is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add some delicious items to get started!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text("Go Back"),
            ),
          ],
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Review Order Items",
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            item.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "Rs. ${item.price.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              onPressed: () => cartNotifier.updateQuantity(
                                item.name,
                                (item.quantity) - 1,
                              ),
                            ),
                            Text(
                              (item.quantity).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                              onPressed: () => cartNotifier.updateQuantity(
                                item.name,
                                (item.quantity) + 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Voucher Code Section - Button to open voucher list
            GestureDetector(
              onTap: () => _openVoucherSelection(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select Voucher',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            if (_appliedVoucher != null && _appliedVoucher!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _appliedVoucher!,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _appliedVoucher = null;
                              _voucherController.clear();
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: colorScheme.onSurface.withValues(alpha: .6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Rs. ${cartNotifier.totalAmount.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => _showConfirmationDialog(context, ref),
                child: const Text(
                  "Proceed to Checkout",
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
}
