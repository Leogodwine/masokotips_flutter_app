import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<ChatMessage>> _chats = {};

  Map<String, List<ChatMessage>> get chats => {..._chats};

  List<ChatMessage> getMessages(String providerId) {
    return _chats[providerId] ?? [];
  }

  void sendMessage(String providerId, String message) {
    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      senderId: 'user123', // Replace with actual user ID
      receiverId: providerId,
      message: message,
      timestamp: DateTime.now(),
    );

    if (!_chats.containsKey(providerId)) {
      _chats[providerId] = [];
    }
    _chats[providerId]!.add(newMessage);
    notifyListeners();
  }

  void markAsRead(String providerId) {
    if (_chats.containsKey(providerId)) {
      for (var message in _chats[providerId]!) {
        if (message.receiverId == 'user123') {
          // Replace with actual user ID
          message = ChatMessage(
            id: message.id,
            senderId: message.senderId,
            receiverId: message.receiverId,
            message: message.message,
            timestamp: message.timestamp,
            isRead: true,
          );
        }
      }
      notifyListeners();
    }
  }
}
