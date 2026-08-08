import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:restro_hub/features/dashboard/logic/membership_rules.dart';

class LoyaltyState {
  final int points;
  final int totalSpent;
  final MembershipTier tier;

  LoyaltyState({
    required this.points,
    required this.totalSpent,
    required this.tier,
  });

  LoyaltyState copyWith({
    int? points,
    int? totalSpent,
    MembershipTier? tier,
  }) {
    return LoyaltyState(
      points: points ?? this.points,
      totalSpent: totalSpent ?? this.totalSpent,
      tier: tier ?? this.tier,
    );
  }
}

class LoyaltyNotifier extends Notifier<LoyaltyState> {
  @override
  LoyaltyState build() {
    // Watch user to reset on logout
    final user = ref.watch(currentUserProvider).value;
    if (user == null) {
      return LoyaltyState(
        points: 0,
        totalSpent: 0,
        tier: MembershipTier.bronze,
      );
    }

    const points = 750;
    return LoyaltyState(
      points: points,
      totalSpent: points * 10, // Assuming 10 Rs per point for mock
      tier: MembershipRules.getTier(points),
    );
  }

  void addPoints(int amount) {
    final newPoints = state.points + amount;
    state = state.copyWith(
      points: newPoints,
      totalSpent: state.totalSpent + (amount * 10),
      tier: MembershipRules.getTier(newPoints),
    );
  }

  void resetPoints() {
    state = LoyaltyState(
      points: 0,
      totalSpent: 0,
      tier: MembershipTier.bronze,
    );
  }
}

final loyaltyProvider = NotifierProvider<LoyaltyNotifier, LoyaltyState>(
  LoyaltyNotifier.new,
);
