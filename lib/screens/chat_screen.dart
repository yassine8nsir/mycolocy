import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet/core/constants/app_colors.dart';
import 'package:mon_projet/models/message_model.dart';
import 'package:mon_projet/providers/auth_provider.dart';
import 'package:mon_projet/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;

  String get _convId => widget.conversation.id;

  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatProvider>();
    chat.loadMessages(_convId);
    chat.joinRoom(_convId);
  }

  @override
  void dispose() {
    context.read<ChatProvider>().leaveRoom(_convId);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTextChanged(String value) {
    final myId = context.read<AuthProvider>().user?.id ?? '';
    final chat = context.read<ChatProvider>();

    if (!_isTyping && value.isNotEmpty) {
      _isTyping = true;
      chat.sendTypingEvent(_convId, myId, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_isTyping) {
        _isTyping = false;
        chat.sendTypingEvent(_convId, myId, false);
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();

    // Stop typing indicator
    _typingTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      final myId = context.read<AuthProvider>().user?.id ?? '';
      context.read<ChatProvider>().sendTypingEvent(_convId, myId, false);
    }

    await context.read<ChatProvider>().sendMessage(_convId, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().user?.id ?? '';
    final chat = context.watch<ChatProvider>();
    final messages = chat.messagesFor(_convId);
    final other = widget.conversation.otherParticipant(myId);
    final someoneTyping = chat.isTyping(_convId);

    // Scroll down when new messages arrive
    if (messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                other.fullName.isNotEmpty
                    ? other.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(other.fullName,
                    style: const TextStyle(fontSize: 15)),
                if (widget.conversation.housing != null)
                  Text(
                    widget.conversation.housing!['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Messages list ────────────────────────────────
          Expanded(
            child: chat.isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(
                        child: Text('Send a message to start chatting',
                            style: TextStyle(color: AppColors.textLight)),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          final isMe = msg.sender.id == myId;
                          final showDate = i == 0 ||
                              !_sameDay(
                                  messages[i - 1].createdAt,
                                  msg.createdAt);

                          return Column(
                            children: [
                              if (showDate) _DateDivider(msg.createdAt),
                              _MessageBubble(msg: msg, isMe: isMe),
                            ],
                          );
                        },
                      ),
          ),

          // ── Typing indicator ─────────────────────────────
          if (someoneTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  Text('${other.fullName.split(' ').first} is typing',
                      style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(width: 6),
                  _TypingDots(),
                ],
              ),
            ),

          // ── Input bar ────────────────────────────────────
          _InputBar(
            controller: _msgCtrl,
            isSending: chat.isSending,
            onChanged: _onTextChanged,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Message bubble ────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textDark,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg.createdAt),
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textLight,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 13,
                    color: msg.isRead
                        ? Colors.lightBlueAccent
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Date divider ──────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider(this.date);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 12)),
        ),
        const Expanded(child: Divider()),
      ]),
    );
  }
}

// ── Typing dots animation ─────────────────────────────────────
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          children: List.generate(3, (i) {
            final opacity = ((_ctrl.value * 3 - i).clamp(0.0, 1.0));
            return Container(
              margin: const EdgeInsets.only(right: 3),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textLight
                    .withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, -2))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: onSend,
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.primary,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
