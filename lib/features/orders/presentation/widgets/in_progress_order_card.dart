import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/core/utils/launcher_utils.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/features/orders/presentation/widgets/order_item_card.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';

class InProgressOrderCard extends StatefulWidget {
  final OrderModel order;
  const InProgressOrderCard({required this.order, super.key});

  @override
  State<InProgressOrderCard> createState() => _InProgressOrderCardState();
}

class _InProgressOrderCardState extends State<InProgressOrderCard> {
  late Timer _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = 5 * 60; // 5 min ETA
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    if (widget.order.subStatus == OrderSubStatus.delivered) {
      return 'Arriving...';
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
    final l10n = AppLocalizations.of(context)!;

    final isPickup = widget.order.subStatus == OrderSubStatus.pickup;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isPickup
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
                          color: isPickup
                              ? Colors.green.withValues(alpha: .1)
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getStatusIcon(widget.order),
                          color: isPickup
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
                              l10n.orderId(widget.order.id),
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _getStatusText(widget.order),
                              style: textTheme.bodySmall?.copyWith(
                                color: isPickup
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

            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?u=driver_active',
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
                      const Text(
                        'Your Delivery Partner',
                        style: TextStyle(fontSize: 10),
                      ),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Item List',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                      isPickup
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

            Column(
              children: widget.order.items.asMap().entries.map((entry) {
                final item = entry.value;
                return OrderItemCard(
                  item: item,
                  isCompact: widget.order.items.length > 3,
                );
              }).toList(),
            ),

            if (widget.order.discount > 0) ...[
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
                    const Text(
                      'Voucher Applied',
                      style: TextStyle(
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
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

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
    if (order.subStatus == OrderSubStatus.preparing) return Icons.soup_kitchen;
    if (order.subStatus == OrderSubStatus.delivered) {
      return Icons.delivery_dining;
    }
    return Icons.check_circle;
  }

  String _getStatusText(OrderModel order) {
    if (order.subStatus == OrderSubStatus.preparing) {
      return 'Cooking your meal...';
    }
    if (order.subStatus == OrderSubStatus.delivered) {
      return 'Out for delivery...';
    }
    return 'Processing...';
  }
}

class _OrderStepProgress extends StatelessWidget {
  final double progress;
  const _OrderStepProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cookingProgress = (progress / 0.33).clamp(0.0, 1.0);
    final packedProgress = ((progress - 0.33) / 0.33).clamp(0.0, 1.0);
    final inRouteProgress = ((progress - 0.66) / 0.34).clamp(0.0, 1.0);

    return Row(
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
  ];
  late Timer _locTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    unawaited(_pulseController.repeat(reverse: true));

    _locTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Is Being Carried',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  _locations[_currentLocationIndex],
                  style: TextStyle(color: colorScheme.primary, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // Open map
            icon: const Icon(Icons.map_outlined, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }
}
