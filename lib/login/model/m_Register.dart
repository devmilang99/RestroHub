import 'package:equatable/equatable.dart';

class ModelRegister extends Equatable {
  const ModelRegister({
    required this.email,
    required this.fullName,
    required this.address,
    required this.phoneNumber,
    required this.password,
  });

  final String email;
  final String fullName;
  final String address;
  final String phoneNumber;
  final String password;

  @override
  List<Object?> get props => [email, fullName, address, phoneNumber, password];
}
