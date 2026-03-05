import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../../models/chat.dart';
import '../chat_repository.dart';
import 'hive_keys.dart';

class HiveChatRepository implements ChatRepository {
  Box<Chat> get _chats => Hive.box<Chat>(HiveKeys.chatsBox);
  Box<List> get _messages => Hive.box<List>(HiveKeys.messagesByChatBox);

  Stream<List<Chat>> _watchBoxAsList() {
    // Emit immediately + on every change.
    late final StreamController<List<Chat>> controller;
    StreamSubscription? sub;

    controller = StreamController<List<Chat>>.broadcast(
      onListen: () {
        controller.add(_sorted(_chats.values.toList()));
        sub = _chats.watch().listen((_) {
          controller.add(_sorted(_chats.values.toList()));
        });
      },
      onCancel: () async {
        await sub?.cancel();
      },
    );

    return controller.stream;
  }

  List<Chat> _sorted(List<Chat> chats) {
    // pinned first, then by updatedAt desc
    chats.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return chats;
  }

  @override
  Stream<List<Chat>> watchAll() => _watchBoxAsList();

  @override
  Future<List<Chat>> getAllOnce() async => _sorted(_chats.values.toList());

  @override
  Future<Chat?> getById(String chatId) async => _chats.get(chatId);

  @override
  Future<Chat> createOrGetDirectChat(String myUserId, String otherUserId) async {
    final existing = _chats.values.firstWhereOrNull((c) {
      final ids = c.participantIds.toSet();
      return ids.contains(myUserId) && ids.contains(otherUserId) && ids.length == 2;
    });

    if (existing != null) return existing;

    final now = DateTime.now();
    final newChat = Chat(
      id: 'c_${now.microsecondsSinceEpoch}',
      participantIds: [myUserId, otherUserId],
      pinned: false,
      unreadCount: 0,
      lastMessageText: '',
      updatedAt: now,
    );

    await _chats.put(newChat.id, newChat);
    await _messages.put(newChat.id, <dynamic>[]); // empty messages list
    return newChat;
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _chats.delete(chatId);
    await _messages.delete(chatId);
    // drafts are managed in MessageRepository
  }

  @override
  Future<void> togglePin(String chatId) async {
    final chat = _chats.get(chatId);
    if (chat == null) return;
    await _chats.put(chatId, chat.copyWith(pinned: !chat.pinned));
  }
}