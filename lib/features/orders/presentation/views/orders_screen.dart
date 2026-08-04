import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:restro_hub/features/orders/presentation/providers/orders_provider.dart';
import 'package:restro_hub/features/orders/presentation/widgets/cancelled_order_card.dart';
import 'package:restro_hub/features/orders/presentation/widgets/in_progress_order_card.dart';
import 'package:restro_hub/features/orders/presentation/widgets/success_order_card.dart';
import 'package:restro_hub/l10n/generated/app_localizations.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = AppLocalizations.of(context)!;

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
            l10n.myOrders,
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
            tabs: [
              Tab(text: l10n.inProgress),
              Tab(text: l10n.success),
              Tab(text: l10n.cancelled),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(statusType: l10n.inProgress),
            _OrderList(statusType: l10n.success),
            _OrderList(statusType: l10n.cancelled),
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
    final ordersAsync = ref.watch(ordersProvider);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = context.colorScheme;

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (orders) {
        final filteredOrders = orders.where((o) {
          if (statusType == l10n.inProgress) {
            return o.subStatus != OrderSubStatus.success &&
                o.subStatus != OrderSubStatus.cancelled;
          } else if (statusType == l10n.success) {
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
                  statusType == l10n.inProgress
                      ? Icons.restaurant_menu_outlined
                      : (statusType == l10n.success
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined),
                  size: 80,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: .2),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noOrdersFound(statusType),
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
                  verticalOffset: 50,
                  child: FadeInAnimation(
                    child: _OrderCard(order: order),
                  ),
                ),
              );
            },
          ),
        );
      },
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
      return InProgressOrderCard(order: order);
    } else if (order.subStatus == OrderSubStatus.success) {
      return SuccessOrderCard(order: order);
    } else {
      return CancelledOrderCard(order: order);
    }
  }
}
