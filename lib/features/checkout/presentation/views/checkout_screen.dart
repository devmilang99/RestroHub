import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/providers/error_service.dart';
import 'package:restro_hub/core/widgets/app_image.dart';
import 'package:restro_hub/features/auth/data/models/user_address_model.dart';
import 'package:restro_hub/features/auth/presentation/providers/address_provider.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/infrastructure/supabase/supabase_service.dart';

class ProcessCheckOut extends ConsumerStatefulWidget {
  const ProcessCheckOut({super.key});

  @override
  ConsumerState<ProcessCheckOut> createState() => _ProcessCheckOutState();
}

class _ProcessCheckOutState extends ConsumerState<ProcessCheckOut> {
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider).value ?? [];
    final totalAmount = cart.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final checkoutState = ref.watch(checkoutProvider);
    final defaultAddress = ref.watch(defaultAddressProvider);
    final displayAddress = checkoutState.selectedAddress ?? defaultAddress;
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
                      TextButton(
                        onPressed: () async {
                          final result = await context.pushNamed<String>(
                            'locationPicker',
                          );
                          if (result != null) {
                            ref
                                .read(checkoutProvider.notifier)
                                .setSelectedAddress(
                                  UserAddressModel(
                                    userId: '',
                                    label: 'Selected',
                                    addressLine1: result,
                                    city: '',
                                  ),
                                );
                          }
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    displayAddress.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    displayAddress.city.isEmpty
                        ? displayAddress.addressLine1
                        : '${displayAddress.addressLine1}, ${displayAddress.city}',
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
          onPressed: _isPlacingOrder
              ? null
              : () async {
                  // Check if user is logged in before placing order
                  final user = ref
                      .read(supabaseClientProvider)
                      .auth
                      .currentUser;
                  if (user == null) {
                    _showLoginRequiredDialog(context);
                    return;
                  }

                  if (cart.isEmpty) {
                    ref
                        .read(errorServiceProvider.notifier)
                        .showError(
                          message:
                              'Your cart is empty. Add some items to place an order.',
                        );
                    return;
                  }

                  setState(() => _isPlacingOrder = true);

                  try {
                    final orderId =
                        'ORD${DateTime.now().millisecondsSinceEpoch}';
                    final restaurantId = cart.isNotEmpty
                        ? cart.first.restaurantId
                        : null;

                    await ref
                        .read(ordersProvider.notifier)
                        .addOrder(
                          OrderModel(
                            id: orderId,
                            restaurantId: restaurantId,
                            items: cart,
                            totalAmount: finalTotal,
                            subStatus: OrderSubStatus.pending,
                            timestamp: DateTime.now(),
                            paymentMethod: checkoutState.paymentMethod,
                            discount: discount,
                          ),
                        );

                    await ref.read(cartProvider.notifier).clearCart();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Order placed successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );

                      // Using path with query parameter for absolute reliability
                      context.go('/mainDashBoard?tab=2');
                    }
                  } on Object catch (e, stack) {
                    ref
                        .read(errorServiceProvider.notifier)
                        .handleException(e, stack);
                  } finally {
                    if (mounted) {
                      setState(() => _isPlacingOrder = false);
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: _isPlacingOrder
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Login Required'),
        content: const Text(
          'You need to be logged in to place an order and track your delivery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/mainLoginScreen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Login Now'),
          ),
        ],
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
