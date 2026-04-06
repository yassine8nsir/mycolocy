import 'user_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final UserModel sender;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversation'] ?? '',
      sender: UserModel.fromJson(json['sender'] is Map
          ? json['sender']
          : {'_id': json['sender'], 'fullName': ''}),
      text: json['text'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class ConversationModel {
  final String id;
  final List<UserModel> participants;
  final MessageModel? lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCounts;
  final Map<String, dynamic>? housing;

  const ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCounts,
    this.housing,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      participants: (json['participants'] as List? ?? [])
          .map((p) => UserModel.fromJson(p))
          .toList(),
      lastMessage: json['lastMessage'] is Map
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : DateTime.now(),
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      housing: json['housing'] is Map ? json['housing'] : null,
    );
  }

  /// Returns the other participant (not the current user).
  UserModel otherParticipant(String myId) =>
      participants.firstWhere(
        (p) => p.id != myId,
        orElse: () => participants.first,
      );

  int unreadFor(String userId) => unreadCounts[userId] ?? 0;
}
