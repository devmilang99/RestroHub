import 'package:equatable/equatable.dart';

class M_ForgotPassword extends Equatable {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  M_ForgotPassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}
