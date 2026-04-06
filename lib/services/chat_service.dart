import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/app_constants.dart';
import '../models/message_model.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();
  io.Socket? _socket;

  // ── Token loader ────────────────────────────────────────────
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) _api.setToken(token);
  }

  // ── Socket.io connection ────────────────────────────────────
  void connectSocket(String token) {
    final serverUrl = AppConstants.baseUrl.replaceAll('/api', '');
    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );
    _socket!.connect();
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', conversationId);
  }

  void sendTyping(String conversationId, String userId, bool isTyping) {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  /// Listen for incoming messages in real time.
  void onNewMessage(void Function(MessageModel) callback) {
    _socket?.on('new_message', (data) {
      try {
        callback(MessageModel.fromJson(Map<String, dynamic>.from(data)));
      } catch (_) {}
    });
  }

  /// Listen for typing events.
  void onTyping(void Function(String userId, bool isTyping) callback) {
    _socket?.on('user_typing', (data) {
      callback(data['userId'] as String, data['isTyping'] as bool);
    });
  }

  void offNewMessage() => _socket?.off('new_message');
  void offTyping() => _socket?.off('user_typing');

  bool get isConnected => _socket?.connected ?? false;

  // ── REST API calls ──────────────────────────────────────────

  Future<ConversationModel> startConversation(
      String recipientId, String? housingId) async {
    await _loadToken();
    final result = await _api.post('/chat/conversations', {
      'recipientId': recipientId,
      if (housingId != null) 'housingId': housingId,
    });
    return ConversationModel.fromJson(result['data']['conversation']);
  }

  Future<List<ConversationModel>> getConversations() async {
    await _loadToken();
    final result = await _api.get('/chat/conversations');
    return (result['data']['conversations'] as List)
        .map((j) => ConversationModel.fromJson(j))
        .toList();
  }

  Future<List<MessageModel>> getMessages(String conversationId,
      {int page = 1}) async {
    await _loadToken();
    final result = await _api
        .get('/chat/conversations/$conversationId/messages?page=$page');
    return (result['data']['messages'] as List)
        .map((j) => MessageModel.fromJson(j))
        .toList();
  }

  Future<MessageModel> sendMessage(
      String conversationId, String text) async {
    await _loadToken();
    final result = await _api.post(
      '/chat/conversations/$conversationId/messages',
      {'text': text},
    );
    return MessageModel.fromJson(result['data']['message']);
  }
}
