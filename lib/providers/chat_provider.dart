import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

class ChatProvider with ChangeNotifier {
  ApiService? _apiService;
  bool _isLoading = false;
  String? _error;

  List<Conversation> _conversations = [];
  final Map<int, List<ChatMessage>> _conversationMessages = {};

  final Map<int, Timer> _pollingTimers = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Conversation> get conversations => _conversations;

  void update(ApiService apiService) {
    _apiService = apiService;
  }

  // Get single conversation's messages
  List<ChatMessage> getMessages(int conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  // Fetch all conversations for the inbox
  Future<void> fetchConversations() async {
    if (_apiService == null) return;
    _setLoading(true);
    try {
      final data = await _apiService!.getConversations();
      _conversations = data.map((json) => Conversation.fromJson(json)).toList();
      _error = null;
    } catch (e) {
      Log.e('Debug fetchConversations error: $e');
      _error = e.toString();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Start a completely new conversation via message
  Future<void> startConversation(int receiverId, String message) async {
    if (_apiService == null) return;
    try {
      final data = await _apiService!.startConversation(receiverId, message);
      final newConversation = Conversation.fromJson(data['data']['conversation']);
      final newMessage = ChatMessage.fromJson(data['data']['message']);
      
      // Update local state smoothly
      if (!_conversations.any((c) => c.id == newConversation.id)) {
        _conversations.insert(0, newConversation);
      }
      
      _conversationMessages[newConversation.id] = [newMessage];
      
      // Attempt to start polling for this new conversation immediately
      startPolling(newConversation.id);
      
      notifyListeners();
    } catch (e) {
      Log.e('startConversation error: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Send message to established conversation
  Future<void> sendMessage(int conversationId, String content) async {
    if (_apiService == null) return;
    try {
      final data = await _apiService!.sendMessage(conversationId, content);
      final newMessage = ChatMessage.fromJson(data['data']);
      
      if (!_conversationMessages.containsKey(conversationId)) {
        _conversationMessages[conversationId] = [];
      }
      _conversationMessages[conversationId]!.add(newMessage);
      notifyListeners();
      
      // Also silently re-fetch conversations to update inbox previews
      _backgroundUpdateConversations();
    } catch (e) {
      Log.e('sendMessage error: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Fetch messages for a specific conversation
  Future<void> fetchConversationMessages(int conversationId) async {
    if (_apiService == null) return;
    try {
      final data = await _apiService!.getConversation(conversationId);
      final convo = Conversation.fromJson(data);
      if (convo.messages != null) {
        _conversationMessages[conversationId] = convo.messages!;
        notifyListeners();
      }
    } catch (e) {
      Log.e('fetchConversationMessages error: $e');
    }
  }

  Future<void> _backgroundUpdateConversations() async {
    if (_apiService == null) return;
    try {
      final data = await _apiService!.getConversations();
      _conversations = data.map((json) => Conversation.fromJson(json)).toList();
      notifyListeners();
    } catch (_) {}
  }

  void startPolling(int conversationId) {
    if (_pollingTimers.containsKey(conversationId)) return;
    
    // Fetch immediately
    fetchConversationMessages(conversationId);
    
    // Then poll every 5 seconds
    _pollingTimers[conversationId] = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchConversationMessages(conversationId);
    });
  }

  void stopPolling(int conversationId) {
    _pollingTimers[conversationId]?.cancel();
    _pollingTimers.remove(conversationId);
  }

  void _setLoading(bool val) {
    _isLoading = val;
  }

  @override
  void dispose() {
    for (var timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();
    super.dispose();
  }
}
