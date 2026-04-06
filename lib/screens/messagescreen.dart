import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/models/message_model.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/chat_provider.dart';
import 'package:mon_projet/screens/chat_screen.dart';

class Messagescreen extends StatefulWidget {
  const Messagescreen({super.key});

  @override
  State<Messagescreen> createState() => _MessagescreenState();
}

class _MessagescreenState extends State<Messagescreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final myId = context.watch<AuthProvider>().user?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          if (chat.totalUnread(myId) > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${chat.totalUnread(myId)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ChatProvider>().loadConversations(),
        child: chat.isLoading && chat.conversations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : chat.conversations.isEmpty
                ? _emptyState()
                : ListView.separated(
                    itemCount: chat.conversations.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, indent: 76),
                    itemBuilder: (_, i) => _ConversationTile(
                      conversation: chat.conversations[i],
                      myId: myId,
                    ),
                  ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 72, color: AppColors.divider),
            const SizedBox(height: 16),
            const Text('No conversations yet',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMedium)),
            const SizedBox(height: 8),
            const Text(
              'Open a listing and tap "Contact Owner"\nto start chatting',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      );
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String myId;

  const _ConversationTile(
      {required this.conversation, required this.myId});

  @override
  Widget build(BuildContext context) {
    final other = conversation.otherParticipant(myId);
    final last = conversation.lastMessage;
    final unread = conversation.unreadFor(myId);
    final hasUnread = unread > 0;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              other.fullName.isNotEmpty
                  ? other.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        other.fullName,
        style: TextStyle(
          fontWeight:
              hasUnread ? FontWeight.bold : FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conversation.housing != null)
            Text(
              conversation.housing!['title'] ?? '',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            last?.text ?? 'Start the conversation',
            style: TextStyle(
              color: hasUnread
                  ? AppColors.textDark
                  : AppColors.textLight,
              fontWeight:
                  hasUnread ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: last != null
          ? Text(
              _formatTime(last.createdAt),
              style: TextStyle(
                color:
                    hasUnread ? AppColors.primary : AppColors.textLight,
                fontSize: 11,
                fontWeight: hasUnread
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            )
          : null,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
