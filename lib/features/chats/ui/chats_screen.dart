import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/chat.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../state/chats_controller.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  Future<User?> _otherUser(WidgetRef ref, Chat chat) async {
    final userRepo = ref.read(userRepositoryProvider);
    final myId = ref.read(currentUserIdProvider);
    final otherId = chat.participantIds.firstWhere((id) => id != myId, orElse: () => myId);
    return userRepo.getById(otherId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsStreamProvider);
    final query = ref.watch(chatsSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search chats...',
              ),
              onChanged: (v) => ref.read(chatsSearchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: chatsAsync.when(
              data: (chats) {
                final q = query.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? chats
                    : chats.where((c) {
                        final inLast = c.lastMessageText.toLowerCase().contains(q);
                        return inLast || c.participantIds.join(',').toLowerCase().contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: q.isEmpty ? Icons.chat_bubble_outline : Icons.search_off_outlined,
                    title: q.isEmpty ? 'No chats yet' : 'No results',
                    subtitle: q.isEmpty
                        ? 'Tap “New chat” to start a conversation.'
                        : 'Try a different search query.',
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final chat = filtered[index];
                    return FutureBuilder<User?>(
                      future: _otherUser(ref, chat),
                      builder: (context, snap) {
                        final other = snap.data;
                        final title = other?.name ?? 'Unknown';
                        return _ChatSlidableTile(
                          chat: chat,
                          title: title,
                          onOpen: () => context.push('/chat/${chat.id}'),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contacts'),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('New chat'),
      ),
    );
  }
}

class _ChatSlidableTile extends ConsumerWidget {
  final Chat chat;
  final String title;
  final VoidCallback onOpen;

  const _ChatSlidableTile({
    required this.chat,
    required this.title,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRepo = ref.read(chatRepositoryProvider);

    // Simple swipe actions without external deps: Dismissible with background left/right.
    return Dismissible(
      key: ValueKey('chat_${chat.id}_${chat.updatedAt.millisecondsSinceEpoch}_${chat.pinned}'),
      background: _swipeBg(
        context,
        alignment: Alignment.centerLeft,
        icon: chat.pinned ? Icons.push_pin_outlined : Icons.push_pin,
        label: chat.pinned ? 'Unpin' : 'Pin',
      ),
      secondaryBackground: _swipeBg(
        context,
        alignment: Alignment.centerRight,
        icon: Icons.delete_outline,
        label: 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          await chatRepo.deleteChat(chat.id);
          return true;
        } else {
          // Pin/unpin
          await chatRepo.togglePin(chat.id);
          return false; // do not dismiss
        }
      },
      child: ListTile(
        onTap: onOpen,
        leading: AppAvatar(name: title),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatChatTime(chat.updatedAt),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        subtitle: Text(
          chat.lastMessageText.isEmpty ? 'No messages yet' : chat.lastMessageText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chat.pinned) const Icon(Icons.push_pin, size: 18),
            if (chat.unreadCount > 0) ...[
              const SizedBox(width: 8),
              _UnreadBadge(count: chat.unreadCount),
            ],
          ],
        ),
      ),
    );
  }

  Widget _swipeBg(BuildContext context,
      {required Alignment alignment, required IconData icon, required String label}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: cs.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w700),
      ),
    );
  }
}