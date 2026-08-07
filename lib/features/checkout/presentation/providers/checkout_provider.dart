import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_hub/features/auth/data/models/user_address_model.dart';

enum PaymentMethod { cod, qr }

class CheckoutState {
  final String? voucherCode;
  final double discount;
  final PaymentMethod paymentMethod;
  final UserAddressModel? selectedAddress;

  CheckoutState({
    this.voucherCode,
    this.discount = 0.0,
    this.paymentMethod = PaymentMethod.cod,
    this.selectedAddress,
  });

  CheckoutState copyWith({
    String? voucherCode,
    double? discount,
    PaymentMethod? paymentMethod,
    UserAddressModel? selectedAddress,
  }) {
    return CheckoutState(
      voucherCode: voucherCode ?? this.voucherCode,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => CheckoutState();

  void setVoucher(String? code, double discount) {
    state = state.copyWith(voucherCode: code, discount: discount);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setSelectedAddress(UserAddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  void reset() {
    state = CheckoutState();
  }
}

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(() {
  return CheckoutNotifier();
});
