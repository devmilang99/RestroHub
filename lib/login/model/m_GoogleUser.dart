import 'package:equatable/equatable.dart';

class GoogleUserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? serverAuthCode;

  const GoogleUserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.serverAuthCode,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, serverAuthCode];
}
