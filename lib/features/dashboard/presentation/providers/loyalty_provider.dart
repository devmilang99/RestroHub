import 'package:flutter_riverpod/legacy.dart';

class LoyaltyNotifier extends StateNotifier<int> {
  LoyaltyNotifier() : super(750); // Mock initial points

  void addPoints(int amount) {
    state += amount;
  }

  void resetPoints() {
    state = 0;
  }
}

final loyaltyProvider = StateNotifierProvider<LoyaltyNotifier, int>((ref) {
  return LoyaltyNotifier();
});
