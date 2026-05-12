import 'user.dart';
import 'chat_message.dart';

class Conversation {
  final int id;
  final int userId;
  final int receiverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final User? receiver;
  final List<ChatMessage>? messages;

  Conversation({
    required this.id,
    required this.userId,
    required this.receiverId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.receiver,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      receiverId: json['receiver_id'] is int ? json['receiver_id'] : int.parse(json['receiver_id'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList()
          : null,
    );
  }

  /// Helper to get the other user in the conversation
  User? getOtherUser(int currentUserId) {
    if (user != null && user!.id == currentUserId) {
      return receiver;
    }
    return user;
  }
}
