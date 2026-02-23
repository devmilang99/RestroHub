import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/cart/data/models/cart_model.dart';

class CartNotifier extends Notifier<List<CartModel>> {
  @override
  List<CartModel> build() => [];

  void addItem(CartModel item) {
    final existingIndex = state.indexWhere((i) => i.name == item.name);
    if (existingIndex != -1) {
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(
          quantity: (existingItem.quantity) + (item.quantity),
        ),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void updateQuantity(String name, int quantity) {
    if (quantity <= 0) {
      removeItem(name);
      return;
    }
    state = [
      for (final item in state)
        if (item.name == name) item.copyWith(quantity: quantity) else item,
    ];
  }

  void removeItem(String name) {
    state = state.where((item) => item.name != name).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalAmount {
    return state.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartModel>>(() {
  return CartNotifier();
});

final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalAmountProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(
    0.0,
    (sum, item) => sum + (item.price * (item.quantity)),
  );
});
