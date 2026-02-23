import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/checkout/presentation/providers/checkout_provider.dart';

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

            // Voucher Code Section
            if (_appliedVoucher == null) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _voucherController,
                      decoration: InputDecoration(
                        hintText: 'Enter Voucher Code',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: .5),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.local_offer_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: .3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_voucherController.text.isNotEmpty) {
                        setState(() {
                          _appliedVoucher = _voucherController.text
                              .toUpperCase();
                        });
                        ref
                            .read(checkoutProvider.notifier)
                            .setVoucher(
                              _appliedVoucher,
                              50.0, // Default mock discount
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Voucher "${_appliedVoucher}" applied',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _openVoucherSelection(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: .3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_alt_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'View Available Vouchers',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
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
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: .2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: .1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_offer,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Applied Voucher',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: .6,
                              ),
                            ),
                          ),
                          Text(
                            _appliedVoucher!,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _appliedVoucher = null;
                          _voucherController.clear();
                        });
                        ref
                            .read(checkoutProvider.notifier)
                            .setVoucher(null, 0.0);
                        _openVoucherSelection(context);
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: colorScheme.error.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              "Select Payment Method",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodCard(
                    context,
                    ref,
                    method: PaymentMethod.cod,
                    icon: Icons.money,
                    label: "Cash on Delivery",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPaymentMethodCard(
                    context,
                    ref,
                    method: PaymentMethod.qr,
                    icon: Icons.qr_code_scanner,
                    label: "QR Payment",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: .2,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: .5),
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    "Subtotal",
                    "Rs. ${cartNotifier.totalAmount.toStringAsFixed(0)}",
                    colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Delivery Fee", "Rs. 40", colorScheme),
                  if (_appliedVoucher != null) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      "Discount",
                      "- Rs. 50", // Mock discount for now
                      colorScheme,
                      isDiscount: true,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rs. ${(cartNotifier.totalAmount + 40 - (_appliedVoucher != null ? 50 : 0)).toStringAsFixed(0)}",
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
                onPressed: () => {context.push('/processCheckout')},
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

  Widget _buildSummaryRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: .6),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? Colors.green : colorScheme.onSurface,
            fontWeight: isDiscount ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    WidgetRef ref, {
    required PaymentMethod method,
    required IconData icon,
    required String label,
  }) {
    final checkoutState = ref.watch(checkoutProvider);
    final isSelected = checkoutState.paymentMethod == method;
    final colorScheme = context.colorScheme;

    return InkWell(
      onTap: () {
        ref.read(checkoutProvider.notifier).setPaymentMethod(method);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: .1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
