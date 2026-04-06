import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  List<ConversationModel> _conversations = [];
  final Map<String, List<MessageModel>> _messages = {};
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  // Typing state: conversationId → isTyping
  final Map<String, bool> _typingStates = {};

  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  List<MessageModel> messagesFor(String conversationId) =>
      _messages[conversationId] ?? [];

  bool isTyping(String conversationId) =>
      _typingStates[conversationId] ?? false;

  // Total unread count across all conversations (for badge)
  int totalUnread(String myId) => _conversations.fold(
      0, (sum, c) => sum + c.unreadFor(myId));

  // ── Socket connection ───────────────────────────────────────
  void connect(String token) {
    _service.connectSocket(token);
  }

  void disconnect() {
    _service.disconnectSocket();
  }

  // ── Start / open a conversation ─────────────────────────────
  Future<ConversationModel?> startConversation(
      String recipientId, String? housingId) async {
    _setLoading(true);
    try {
      final conv =
          await _service.startConversation(recipientId, housingId);

      // Insert if not already in the list
      if (!_conversations.any((c) => c.id == conv.id)) {
        _conversations.insert(0, conv);
        notifyListeners();
      }
      return conv;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── Load conversation list ──────────────────────────────────
  Future<void> loadConversations() async {
    _setLoading(true);
    try {
      _conversations = await _service.getConversations();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // ── Load messages for a conversation ───────────────────────
  Future<void> loadMessages(String conversationId) async {
    _setLoading(true);
    try {
      final msgs = await _service.getMessages(conversationId);
      _messages[conversationId] = msgs;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ── Send a message ──────────────────────────────────────────
  Future<void> sendMessage(String conversationId, String text) async {
    _isSending = true;
    notifyListeners();
    try {
      final msg = await _service.sendMessage(conversationId, text);
      _appendMessage(conversationId, msg);
      _updateConversationLastMessage(conversationId, msg);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ── Join a conversation room (Socket.io) ────────────────────
  void joinRoom(String conversationId) {
    _service.joinConversation(conversationId);

    _service.onNewMessage((msg) {
      if (msg.conversationId == conversationId) {
        _appendMessage(conversationId, msg);
        _updateConversationLastMessage(conversationId, msg);
      }
    });

    _service.onTyping((userId, isTyping) {
      _typingStates[conversationId] = isTyping;
      notifyListeners();
    });
  }

  void leaveRoom(String conversationId) {
    _service.leaveConversation(conversationId);
    _service.offNewMessage();
    _service.offTyping();
    _typingStates.remove(conversationId);
  }

  void sendTypingEvent(String conversationId, String userId, bool isTyping) {
    _service.sendTyping(conversationId, userId, isTyping);
  }

  // ── Helpers ─────────────────────────────────────────────────
  void _appendMessage(String conversationId, MessageModel msg) {
    _messages.putIfAbsent(conversationId, () => []);
    final existing = _messages[conversationId]!;
    if (!existing.any((m) => m.id == msg.id)) {
      existing.add(msg);
      notifyListeners();
    }
  }

  void _updateConversationLastMessage(
      String conversationId, MessageModel msg) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      // Move updated conversation to top
      final conv = _conversations.removeAt(idx);
      _conversations.insert(0, conv);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
