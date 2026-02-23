import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMethod { cod, qr }

class CheckoutState {
  final String? voucherCode;
  final double discount;
  final PaymentMethod paymentMethod;

  CheckoutState({
    this.voucherCode,
    this.discount = 0.0,
    this.paymentMethod = PaymentMethod.cod,
  });

  CheckoutState copyWith({
    String? voucherCode,
    double? discount,
    PaymentMethod? paymentMethod,
  }) {
    return CheckoutState(
      voucherCode: voucherCode ?? this.voucherCode,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
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

  void reset() {
    state = CheckoutState();
  }
}

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(() {
  return CheckoutNotifier();
});
