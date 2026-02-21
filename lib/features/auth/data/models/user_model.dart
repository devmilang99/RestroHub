import 'package:equatable/equatable.dart';

/// User Model for Authentication.
/// Follows Clean Architecture by being a plain data object.
class UserModel extends Equatable {
  final String email;
  final String password;

  const UserModel({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
