import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/utils/launcher_utils.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';
import 'package:restro_hub/features/cart/presentation/providers/cart_provider.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: colorScheme.surface,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'My Orders',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'In Progress'),
              Tab(text: 'Success'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderList(statusType: 'In Progress'),
            _OrderList(statusType: 'Success'),
            _OrderList(statusType: 'Cancelled'),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  final String statusType;
  const _OrderList({required this.statusType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    final colorScheme = context.colorScheme;
    final filteredOrders = orders.where((o) {
      if (statusType == 'In Progress') {
        return o.subStatus != OrderSubStatus.success &&
            o.subStatus != OrderSubStatus.cancelled;
      } else if (statusType == 'Success') {
        return o.subStatus == OrderSubStatus.success;
      } else {
        return o.subStatus == OrderSubStatus.cancelled;
      }
    }).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusType == 'In Progress'
                  ? Icons.restaurant_menu_outlined
                  : (statusType == 'Success'
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined),
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .2),
            ),
            const SizedBox(height: 16),
            Text(
              'No $statusType orders found',
              style: context.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _OrderCard(order: order),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.subStatus != OrderSubStatus.success &&
        order.subStatus != OrderSubStatus.cancelled) {
      return _InProgressOrderCard(order: order);
    } else if (order.subStatus == OrderSubStatus.success) {
      return _SuccessOrderCard(order: order);
    } else {
      return _CancelledOrderCard(order: order);
    }
  }
}

class _SuccessOrderCard extends ConsumerStatefulWidget {
  final OrderModel order;
  const _SuccessOrderCard({required this.order});

  @override
  ConsumerState<_SuccessOrderCard> createState() => _SuccessOrderCardState();
}

class _SuccessOrderCardState extends ConsumerState<_SuccessOrderCard> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  int _wordCount = 0;
  String? _sentFeedback;
  DateTime? _sentTimestamp;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _feedbackController
      ..removeListener(_updateWordCount)
      ..dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      setState(() => _wordCount = 0);
      return;
    }
    final words = text.split(RegExp(r'\s+'));
    setState(() => _wordCount = words.length);
  }

  void _sendFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    if (_wordCount > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback cannot exceed 20 words')),
      );
      return;
    }

    // Save feedback and timestamp
    setState(() {
      _sentFeedback = _feedbackController.text.trim();
      _sentTimestamp = DateTime.now();
    });

    // TODO(user): Save feedback to backend/database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback sent! ($_wordCount words)'),
        backgroundColor: Colors.green,
      ),
    );

    _feedbackController.clear();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.green.withValues(alpha: .3), width: 2),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${widget.order.id}',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Delivered successfully',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${widget.order.totalAmount.toStringAsFixed(0)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.order.discount > 0 ? Colors.green : null,
                      ),
                    ),
                    if (widget.order.discount > 0)
                      Text(
                        'Rs. ${(widget.order.totalAmount + widget.order.discount).toStringAsFixed(0)}',
                        style: textTheme.labelSmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://i.pravatar.cc/150?u=driver_success',
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rohan Sharma',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Delivered by', style: textTheme.bodySmall),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => GestureDetector(
                        onTap: _sentFeedback == null
                            ? () {
                                setState(() {
                                  _rating = i + 1;
                                });
                              }
                            : null,
                        child: Icon(
                          i < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Item Table Layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Column(
                  children: widget.order.items.asMap().entries.map((entry) {
                    final item = entry.value;
                    return _buildOrderItemCard(
                      context,
                      item,
                      isCompact: widget.order.items.length > 3,
                    );
                  }).toList(),
                ),
                if (widget.order.voucherCode != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_offer,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Voucher Applied: ${widget.order.voucherCode}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '- Rs. ${widget.order.discount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),
              ],
            ),
            // Feedback Box or Sent Feedback Card
            if (_sentFeedback == null)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _feedbackController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Share your feedback...',
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_wordCount / 20 words',
                            style: TextStyle(
                              fontSize: 11,
                              color: _wordCount > 20
                                  ? Colors.red
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: _wordCount > 20
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Row(
                            children: [
                              if (_wordCount > 20)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Text(
                                    'Limit exceeded!',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              InkWell(
                                onTap: _sendFeedback,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _wordCount > 0 && _wordCount <= 20
                                        ? colorScheme.primary
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    size: 16,
                                    color: _wordCount > 0 && _wordCount <= 20
                                        ? Colors.white
                                        : Colors.grey.shade600,
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
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_rounded,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Feedback Sent!',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              if (_sentTimestamp != null)
                                Text(
                                  _formatTimestamp(_sentTimestamp!),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.green.shade600,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _feedbackController.text = _sentFeedback!;
                              _sentFeedback = null;
                              _sentTimestamp = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        _sentFeedback!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for helping us improve',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Order Again Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _reorder(ref, context, widget.order),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Order Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _reorder(WidgetRef ref, BuildContext context, OrderModel order) {
  unawaited(
    showDialog<void>(
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
                unawaited(cartNotifier.addItem(item));
              }
              Navigator.pop(context);
              context.pushNamed('processCheckout');
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    ),
  );
}

class _CancelledOrderCard extends ConsumerWidget {
  final OrderModel order;
  const _CancelledOrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red.withValues(alpha: .3), width: 2),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Order cancelled',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://i.pravatar.cc/150?u=driver_cancelled',
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rohan Sharma',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Assigned Driver', style: textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      unawaited(LauncherUtils.launchPhone('+9779812345678')),
                  icon: Icon(Icons.phone, color: colorScheme.primary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            const Text(
              'Order Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Column(
              children: order.items
                  .map((item) => _buildOrderItemCard(context, item))
                  .toList(),
            ),
            if (order.voucherCode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Voucher Applied: ${order.voucherCode}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '- Rs. ${order.discount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Cancellation Reason
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancellation Reason',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Restaurant busy - Unable to fulfill order',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Order Again Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _reorder(ref, context, order),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Order Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildOrderItemCard(
  BuildContext context,
  CartModel item, {
  bool isCompact = false,
}) {
  final colorScheme = context.colorScheme;
  final textTheme = context.textTheme;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    margin: EdgeInsets.only(bottom: isCompact ? 6 : 10),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: colorScheme.brightness == Brightness.dark ? 0.2 : 0.05,
          ),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(isCompact ? 6.0 : 8.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCompact ? 35 : 50,
            height: isCompact ? 35 : 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.fastfood, size: isCompact ? 16 : 20),
                ),
              ),
            ),
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
                    fontSize: isCompact ? 13 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: isCompact ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              fontSize: isCompact ? 13 : 14,
            ),
          ),
        ],
      ),
    ),
  );
}

class _InProgressOrderCard extends StatefulWidget {
  final OrderModel order;
  const _InProgressOrderCard({required this.order});

  @override
  State<_InProgressOrderCard> createState() => _InProgressOrderCardState();
}

class _InProgressOrderCardState extends State<_InProgressOrderCard> {
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _getInitialSeconds();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int _getInitialSeconds() {
    return 5 * 60; // Reset ETA to 5 min as requested
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    if (widget.order.subStatus == OrderSubStatus.pickup) {
      return 'Driver Waiting';
    }
    if (totalSeconds <= 0) return 'Arriving...';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: widget.order.subStatus == OrderSubStatus.pickup
              ? Colors.green.withValues(alpha: .5)
              : Colors.amber.withValues(alpha: .5),
          width: 2,
        ),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.order.subStatus == OrderSubStatus.pickup
                              ? Colors.green.withValues(alpha: .1)
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getStatusIcon(widget.order),
                          color: widget.order.subStatus == OrderSubStatus.pickup
                              ? Colors.green
                              : colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${widget.order.id}',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getStatusText(widget.order),
                              style: textTheme.bodySmall?.copyWith(
                                color:
                                    widget.order.subStatus ==
                                        OrderSubStatus.pickup
                                    ? Colors.green
                                    : colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${widget.order.totalAmount.toStringAsFixed(0)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.order.discount > 0 ? Colors.green : null,
                      ),
                    ),
                    if (widget.order.discount > 0)
                      Text(
                        'Rs. ${(widget.order.totalAmount + widget.order.discount).toStringAsFixed(0)}',
                        style: textTheme.labelSmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://i.pravatar.cc/150?u=driver_active',
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rohan Sharma',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Your Delivery Partner', style: textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      unawaited(LauncherUtils.launchPhone('+9779812345678')),
                  icon: Icon(Icons.phone, color: colorScheme.primary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Header for items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Item List',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.order.subStatus == OrderSubStatus.pickup
                          ? 'Driver Waiting'
                          : 'ETA: ${_formatTimer(_secondsRemaining)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item List using Cards instead of Table for better aesthetics
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: widget.order.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  return _buildOrderItemCard(
                    context,
                    item,
                    isCompact: widget.order.items.length > 3,
                  );
                }).toList(),
              ),
            ),

            if (widget.order.voucherCode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Voucher Applied: ${widget.order.voucherCode}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '- Rs. ${widget.order.discount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Progress Tracker or Live Tracking bar
            if (widget.order.subStatus == OrderSubStatus.preparing)
              _OrderStepProgress(progress: widget.order.progress)
            else
              _LiveTrackingBar(order: widget.order),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(OrderModel order) {
    if (order.subStatus == OrderSubStatus.preparing) {
      if (order.progress < 0.33) return Icons.soup_kitchen;
      if (order.progress < 0.66) return Icons.inventory_2;
      return Icons.delivery_dining;
    }
    if (order.subStatus == OrderSubStatus.delivered) {
      return Icons.delivery_dining;
    }
    if (order.subStatus == OrderSubStatus.pickup) return Icons.shopping_bag;
    return Icons.check_circle;
  }

  String _getStatusText(OrderModel order) {
    if (order.subStatus == OrderSubStatus.preparing) {
      if (order.progress < 0.33) return 'Cooking your meal...';
      if (order.progress < 0.66) return 'Meal is being packed...';
      return 'Out for delivery...';
    }
    if (order.subStatus == OrderSubStatus.delivered) {
      return 'Order being carried...';
    }
    if (order.subStatus == OrderSubStatus.pickup) return 'Driver is Waiting';
    return 'Completed';
  }
}

class _OrderStepProgress extends StatelessWidget {
  final double progress;
  const _OrderStepProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    // Stage 1: Cooking (0.0 - 0.33)
    final cookingProgress = (progress / 0.33).clamp(0.0, 1.0);
    // Stage 2: Packed (0.33 - 0.66)
    final packedProgress = ((progress - 0.33) / 0.33).clamp(0.0, 1.0);
    // Stage 3: In Route (0.66 - 1.0)
    final inRouteProgress = ((progress - 0.66) / 0.34).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            _ProgressStep(
              label: 'Cooking',
              icon: Icons.soup_kitchen,
              progress: cookingProgress,
              isCompleted: progress > 0.33,
            ),
            _ProgressStep(
              label: 'Packed',
              icon: Icons.inventory_2,
              progress: packedProgress,
              isCompleted: progress > 0.66,
            ),
            _ProgressStep(
              label: 'In Route',
              icon: Icons.delivery_dining,
              progress: inRouteProgress,
              isCompleted: progress >= 1.0,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final double progress;
  final bool isCompleted;

  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = progress > 0;

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: isCompleted
                ? Colors.green
                : (isActive ? colorScheme.primary : Colors.grey.shade400),
            size: 24,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : colorScheme.primary,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isCompleted
                  ? Colors.green
                  : (isActive ? colorScheme.primary : Colors.grey.shade600),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LiveTrackingBar extends StatefulWidget {
  final OrderModel order;
  const _LiveTrackingBar({required this.order});

  @override
  State<_LiveTrackingBar> createState() => _LiveTrackingBarState();
}

class _LiveTrackingBarState extends State<_LiveTrackingBar>
    with SingleTickerProviderStateMixin {
  int _currentLocationIndex = 0;
  final List<String> _locations = [
    'Driver is at the Restaurant',
    'Passing through New Road',
    'Near Civil Mall',
    'Approaching Narayan Chowk',
    'Arriving at Your Location',
    'Arrived! Driver is Waiting',
  ];
  late Timer _locTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    unawaited(_pulseController.repeat(reverse: true));

    _pulseAnimation = Tween<double>(
      begin: 0.1,
      end: 0.25,
    ).animate(_pulseController);

    _locTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentLocationIndex < _locations.length - 1) {
        if (mounted) {
          setState(() {
            _currentLocationIndex++;
          });
        }
      } else {
        _locTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _locTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArrived = widget.order.subStatus == OrderSubStatus.pickup;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(
                  alpha: isArrived ? 0.2 : _pulseAnimation.value,
                ),
                colorScheme.primary.withValues(alpha: isArrived ? 0.3 : 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isArrived
                  ? Colors.green.withValues(alpha: 0.5)
                  : colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              if (isArrived)
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Row(
            children: [
              if (isArrived)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1.1),
                  duration: const Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.green,
                        size: 28,
                      ),
                    );
                  },
                )
              else
                _MovingIcon(color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArrived ? 'PLEASE PICK UP!' : 'Order Is Being Carried',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isArrived ? Colors.green.shade700 : null,
                      ),
                    ),
                    Text(
                      isArrived
                          ? 'The driver is waiting for you'
                          : _locations[_currentLocationIndex < _locations.length
                                ? _currentLocationIndex
                                : _locations.length - 1],
                      style: TextStyle(
                        color: isArrived
                            ? Colors.green.shade600
                            : colorScheme.primary,
                        fontSize: 11,
                        fontWeight: isArrived ? FontWeight.w500 : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (isArrived)
                const _BlinkingIcon(icon: Icons.hail, color: Colors.green)
              else
                IconButton(
                  onPressed: () => _openTrackingSheet(context),
                  icon: const Icon(
                    Icons.map_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openTrackingSheet(BuildContext context) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const _DriverTrackingSheet(),
      ),
    );
  }
}

class _MovingIcon extends StatefulWidget {
  final Color color;
  const _MovingIcon({required this.color});

  @override
  State<_MovingIcon> createState() => _MovingIconState();
}

class _MovingIconState extends State<_MovingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _move;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    unawaited(_ctrl.repeat());
    _move = Tween<double>(begin: -2, end: 2).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _move,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_move.value, 0),
          child: Icon(Icons.delivery_dining, color: widget.color, size: 24),
        );
      },
    );
  }
}

class _BlinkingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _BlinkingIcon({required this.icon, required this.color});

  @override
  State<_BlinkingIcon> createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<_BlinkingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    unawaited(_ctrl.repeat(reverse: true));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Icon(widget.icon, color: widget.color),
    );
  }
}

class _DriverTrackingSheet extends StatefulWidget {
  const _DriverTrackingSheet();

  @override
  State<_DriverTrackingSheet> createState() => _DriverTrackingSheetState();
}

class _DriverTrackingSheetState extends State<_DriverTrackingSheet> {
  GoogleMapController? _controller;
  late Timer _markerTimer;

  // Mock coordinates for Nepal (Kathmandu area)
  static const LatLng _restaurantLoc = LatLng(27.700769, 85.300140);
  static const LatLng _deliveryLoc = LatLng(27.7172, 85.3240); // Destination

  LatLng _driverLoc = _restaurantLoc;
  int _step = 0;
  final int _totalSteps = 10;

  @override
  void initState() {
    super.initState();
    _markerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_step < _totalSteps) {
        if (mounted) {
          setState(() {
            _step++;
            // Interpolate position
            final lat =
                _restaurantLoc.latitude +
                (_deliveryLoc.latitude - _restaurantLoc.latitude) *
                    (_step / _totalSteps);
            final lng =
                _restaurantLoc.longitude +
                (_deliveryLoc.longitude - _restaurantLoc.longitude) *
                    (_step / _totalSteps);
            _driverLoc = LatLng(lat, lng);
          });
          unawaited(
            _controller?.animateCamera(CameraUpdate.newLatLng(_driverLoc)),
          );
        }
      } else {
        _markerTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _markerTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _driverLoc,
                zoom: 15,
              ),
              onMapCreated: (controller) => _controller = controller,
              markers: {
                Marker(
                  markerId: const MarkerId('restaurant'),
                  position: _restaurantLoc,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('delivery'),
                  position: _deliveryLoc,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('driver'),
                  position: _driverLoc,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
              // TODO(user): Add Google Maps API key in AndroidManifest.xml and AppDelegate.swift
            ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        size: 40,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Driver is on the way',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _step == _totalSteps
                                  ? 'Arrived!'
                                  : 'Estimated time: ${(_totalSteps - _step) * 2} mins',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
