import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoyaltyNotifier extends Notifier<int> {
  @override
  int build() => 750;

  void addPoints(int amount) {
    state += amount;
  }

  void resetPoints() {
    state = 0;
  }
}

final loyaltyProvider = NotifierProvider<LoyaltyNotifier, int>(() {
  return LoyaltyNotifier();
});
