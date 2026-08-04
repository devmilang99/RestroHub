import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class AiChatMessage extends Equatable {
  final String id;
  final String? text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.isUser, String? id,
    this.text,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [id, text, isUser, timestamp];

  AiChatMessage copyWith({
    String? text,
    bool? isUser,
  }) {
    return AiChatMessage(
      id: id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp,
    );
  }
}
