import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:masoko_tips/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final int? conversationId;
  final int receiverId;
  final String receiverName;
  final String receiverImage;

  const ChatScreen({
    super.key,
    this.conversationId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  
  // Track our actual conversation ID. If null initially, it will be populated
  // after the first message is sent via the provider.
  int? _activeConversationId;

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    
    if (_activeConversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ChatProvider>();
        provider.startPolling(_activeConversationId!);
      });
    }
  }

  @override
  void dispose() {
    if (_activeConversationId != null) {
      context.read<ChatProvider>().stopPolling(_activeConversationId!);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    
    try {
      final provider = context.read<ChatProvider>();
      
      if (_activeConversationId == null) {
        // First message - creates conversation
        await provider.startConversation(widget.receiverId, text);
        
        if (!mounted) return;

        // Find the new conversation ID to start polling
        final newConv = provider.conversations.firstWhere(
            (c) => c.receiverId == widget.receiverId || c.userId == widget.receiverId);
        setState(() {
          _activeConversationId = newConv.id;
        });
      } else {
        // Send to existing conversation
        await provider.sendMessage(_activeConversationId!, text);
      }
      
      if (!mounted) return;
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id ?? 0;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverImage.isNotEmpty 
                  ? NetworkImage(widget.receiverImage) 
                  : null,
              child: widget.receiverImage.isEmpty 
                  ? const Icon(Icons.person) 
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.receiverName,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (_activeConversationId == null) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.sayHello),
                  );
                }
                
                final messages = provider.getMessages(_activeConversationId!);
                
                if (messages.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.noMessagesYet));
                }
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // _scrollToBottom(); // Removed to prevent forced scrolling on every poll
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.userId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24, top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        color: Theme.of(context).primaryColor,
                        onPressed: _sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
