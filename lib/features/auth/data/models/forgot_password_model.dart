import 'package:equatable/equatable.dart';

class ForgotPasswordModel extends Equatable {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ForgotPasswordModel({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}
