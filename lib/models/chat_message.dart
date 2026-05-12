import 'user.dart';

class ChatMessage {
  final int id;
  final int conversationId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      conversationId: json['conversation_id'] is int 
          ? json['conversation_id'] 
          : int.parse(json['conversation_id'].toString()),
      userId: json['user_id'] is int 
          ? json['user_id'] 
          : int.parse(json['user_id'].toString()),
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  // Helper properties backwards compatibility during refactor
  String get message => content;
  DateTime get timestamp => createdAt;
}
