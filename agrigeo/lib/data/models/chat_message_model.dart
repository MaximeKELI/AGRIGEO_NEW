import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

@JsonSerializable()
class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  ChatMessageModel copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}




