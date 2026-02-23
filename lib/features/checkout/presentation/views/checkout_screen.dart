import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/checkout/presentation/providers/checkout_provider.dart';
import 'dart:ui';

class ProcessCheckOut extends ConsumerWidget {
  const ProcessCheckOut({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totalAmount = cart.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final checkoutState = ref.watch(checkoutProvider);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    const double deliveryCharge = 40.0;
    final discount = checkoutState.discount;
    final finalTotal = totalAmount + deliveryCharge - discount;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            stretch: true,
            backgroundColor: colorScheme.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
              style: IconButton.styleFrom(backgroundColor: Colors.black26),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    "https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colorScheme.surface.withValues(alpha: .8),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: .2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Ready for Checkout",
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "Your delicious order is just a tap away",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Order ID and Time
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order ID: #RH-987BC",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Preparing",
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Today, 2:45 PM",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Delivery Address
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              Icons.location_on,
              "Delivery Address",
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.home,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Milan Ghimire",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Bharatpur-12, Chitwan, Nepal",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          "+977-9800000000",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Order Items
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              Icons.restaurant,
              "Your Order from Cuisine",
            ),
          ),
          SliverToBoxAdapter(child: _buildOrderItemsTable(context, cart)),

          // Voucher Section
          if (checkoutState.voucherCode != null) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                Icons.confirmation_num,
                "Voucher Applied",
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: .3,
                  ),
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
                        Icons.discount,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkoutState.voucherCode!,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Saving your appetite & wallet',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '- Rs. ${checkoutState.discount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Payment Method Confirmation
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              Icons.payment,
              "Payment Method",
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: .3,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    checkoutState.paymentMethod == PaymentMethod.cod
                        ? Icons.money
                        : Icons.qr_code_scanner,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    checkoutState.paymentMethod == PaymentMethod.cod
                        ? "Cash on Delivery"
                        : "QR Payment",
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
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
                    color: Colors.black.withAlpha(20),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(context, "Item Total", totalAmount),
                  _buildSummaryRow(context, "Delivery Fee", deliveryCharge),
                  _buildSummaryRow(
                    context,
                    "Voucher Discount",
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
                        "Grand Total",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rs. ${finalTotal.toStringAsFixed(0)}",
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

          // Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            ref.read(cartProvider.notifier).clearCart();
            ref.read(checkoutProvider.notifier).reset();
            context.goNamed("mainDashBoard");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 55),
            elevation: 8,
            shadowColor: colorScheme.primary.withValues(alpha: .4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            "Confirm Order",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsTable(BuildContext context, List<dynamic> cart) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No items in cart', style: textTheme.bodyLarge),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: List.generate(cart.length, (index) {
          final item = cart[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // Item image thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Cuisine",
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.local_fire_department_outlined,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Hot",
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quantity & Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "x${item.quantity}",
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rs. ${(item.price * item.quantity).toStringAsFixed(0)}",
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
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
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            "${isDiscount ? '-' : ''}Rs. ${amount.abs().toStringAsFixed(0)}",
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDiscount ? Colors.green : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
