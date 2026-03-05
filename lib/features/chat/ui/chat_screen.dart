import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/chat.dart';
import '../../../data/models/message.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../state/chat_controller.dart';
import 'message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription? _messagesSub;

  @override
  void initState() {
    super.initState();

    // Load draft once.
    Future.microtask(() async {
      final draft = await ref.read(draftProvider(widget.chatId).future);
      if (mounted) {
        _controller.text = draft;
        setState(() {});
      }
    });

    // Autosave draft with a small debounce.
    Timer? debounce;
    _controller.addListener(() {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 250), () {
        ref.read(messageRepositoryProvider).setDraft(widget.chatId, _controller.text);
      });
      setState(() {});
    });

    // Auto-scroll on new messages
    Future.microtask(() {
      final stream = ref.read(messageRepositoryProvider).watchByChat(widget.chatId);
      _messagesSub = stream.listen((_) => _scrollToBottomSoon());
    });
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<User?> _otherUser(Chat chat) async {
    final userRepo = ref.read(userRepositoryProvider);
    final myId = ref.read(currentUserIdProvider);
    final otherId = chat.participantIds.firstWhere((id) => id != myId, orElse: () => myId);
    return userRepo.getById(otherId);
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final msgRepo = ref.watch(messageRepositoryProvider);
    final myId = ref.watch(currentUserIdProvider);

    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatId));
    final replyState = ref.watch(replyStateProvider(widget.chatId));

    return FutureBuilder<Chat?>(
      future: chatRepo.getById(widget.chatId),
      builder: (context, chatSnap) {
        final chat = chatSnap.data;
        if (chat == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const EmptyState(
              title: 'Chat not found',
              subtitle: 'It may have been deleted.',
              icon: Icons.warning_amber_outlined,
            ),
          );
        }

        return FutureBuilder<User?>(
          future: _otherUser(chat),
          builder: (context, userSnap) {
            final other = userSnap.data;
            final title = other?.name ?? 'Unknown';
            final status = (other?.isOnline ?? false)
                ? 'online'
                : 'last seen (mock)';

            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                title: Row(
                  children: [
                    const SizedBox(width: 8),
                    AppAvatar(name: title, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(
                            status,
                            style: Theme.of(context).textTheme.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: messagesAsync.when(
                      data: (messages) {
                        if (messages.isEmpty) {
                          return const EmptyState(
                            title: 'No messages',
                            subtitle: 'Say hi 👋',
                            icon: Icons.chat_bubble_outline,
                          );
                        }

                        final items = _buildWithDayHeaders(messages);

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            if (item is _DayHeader) {
                              return _DayHeaderWidget(text: item.text);
                            }
                            final msg = item as Message;

                            final isMine = msg.senderId == myId;
                            final replyPreviewText = msg.replyToMessageId == null
                                ? null
                                : messages
                                    .firstWhere(
                                      (m) => m.id == msg.replyToMessageId,
                                      orElse: () => Message(
                                        id: 'missing',
                                        chatId: msg.chatId,
                                        senderId: '',
                                        text: '(message not found)',
                                        sentAt: msg.sentAt,
                                      ),
                                    )
                                    .text;

                            return MessageBubble(
                              message: msg,
                              isMine: isMine,
                              replyPreviewText: replyPreviewText,
                              onLongPress: () => _showMessageActions(
                                context,
                                msg: msg,
                                onCopy: () async {
                                  await Clipboard.setData(ClipboardData(text: msg.text));
                                },
                                onDelete: () async {
                                  await msgRepo.deleteMessage(widget.chatId, msg.id);
                                },
                                onReply: () {
                                  ref.read(replyStateProvider(widget.chatId).notifier).state =
                                      ReplyState(msg);
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Error: $e')),
                    ),
                  ),
                  if (replyState != null) _ReplyBar(
                    text: replyState.message.text,
                    onClose: () => ref.read(replyStateProvider(widget.chatId).notifier).state = null,
                  ),
                  _Composer(
                    controller: _controller,
                    onSend: () async {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;

                      final replyTo = ref.read(replyStateProvider(widget.chatId))?.message.id;

                      await msgRepo.sendMessage(
                        chatId: widget.chatId,
                        senderId: myId,
                        text: text,
                        replyToMessageId: replyTo,
                      );

                      _controller.clear();
                      ref.read(replyStateProvider(widget.chatId).notifier).state = null;

                      await msgRepo.setDraft(widget.chatId, '');
                      _scrollToBottomSoon();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Object> _buildWithDayHeaders(List<Message> messages) {
    final result = <Object>[];
    DateTime? lastDay;
    for (final m in messages) {
      final day = dateOnly(m.sentAt);
      if (lastDay == null || !isSameDay(day, lastDay)) {
        result.add(_DayHeader(formatDayHeader(m.sentAt)));
        lastDay = day;
      }
      result.add(m);
    }
    return result;
  }

  Future<void> _showMessageActions(
    BuildContext context, {
    required Message msg,
    required Future<void> Function() onCopy,
    required Future<void> Function() onDelete,
    required VoidCallback onReply,
  }) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy'),
                onTap: () async {
                  Navigator.pop(context);
                  await onCopy();
                },
              ),
              ListTile(
                leading: const Icon(Icons.reply_outlined),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
                  onReply();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context);
                  await onDelete();
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

class _DayHeader {
  final String text;
  _DayHeader(this.text);
}

class _DayHeaderWidget extends StatelessWidget {
  final String text;
  const _DayHeaderWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(text, style: Theme.of(context).textTheme.labelMedium),
        ),
      ),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  final String text;
  final VoidCallback onClose;

  const _ReplyBar({required this.text, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            tooltip: 'Cancel reply',
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _Composer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final canSend = controller.text.trim().isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: canSend ? onSend : null,
              icon: const Icon(Icons.send),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}