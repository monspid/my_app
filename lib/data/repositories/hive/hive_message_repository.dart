import 'dart:async';

import 'package:hive/hive.dart';

import '../../models/message.dart';
import '../../models/chat.dart';
import '../message_repository.dart';
import 'hive_keys.dart';

class HiveMessageRepository implements MessageRepository {
  Box<List> get _messages => Hive.box<List>(HiveKeys.messagesByChatBox);
  Box<String> get _drafts => Hive.box<String>(HiveKeys.draftsBox);
  Box<Chat> get _chats => Hive.box<Chat>(HiveKeys.chatsBox);

  Stream<List<Message>> _watchChatMessages(String chatId) {
    late final StreamController<List<Message>> controller;
    StreamSubscription? sub;

    controller = StreamController<List<Message>>.broadcast(
      onListen: () {
        controller.add(_getList(chatId));
        sub = _messages.watch(key: chatId).listen((_) {
          controller.add(_getList(chatId));
        });
      },
      onCancel: () async {
        await sub?.cancel();
      },
    );

    return controller.stream;
  }

  List<Message> _getList(String chatId) {
    final raw = _messages.get(chatId, defaultValue: <dynamic>[])!;
    final list = raw.cast<Message>().toList();
    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }

  Future<void> _putList(String chatId, List<Message> list) async {
    // Hive box typed as List (dynamic) but we store List<Message>.
    await _messages.put(chatId, list);
  }

  @override
  Stream<List<Message>> watchByChat(String chatId) => _watchChatMessages(chatId);

  @override
  Future<List<Message>> getByChatOnce(String chatId) async => _getList(chatId);

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? replyToMessageId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final now = DateTime.now();
    final msg = Message(
      id: 'm_${now.microsecondsSinceEpoch}',
      chatId: chatId,
      senderId: senderId,
      text: trimmed,
      sentAt: now,
      replyToMessageId: replyToMessageId,
    );

    final list = _getList(chatId);
    list.add(msg);
    await _putList(chatId, list);

    // Update chat preview & updatedAt
    final chat = _chats.get(chatId);
    if (chat != null) {
      await _chats.put(
        chatId,
        chat.copyWith(
          lastMessageText: trimmed,
          updatedAt: now,
          unreadCount: 0, // prototype: mark as read when you send
        ),
      );
    }
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    final list = _getList(chatId);
    list.removeWhere((m) => m.id == messageId);
    await _putList(chatId, list);

    // Update chat preview based on last message
    final chat = _chats.get(chatId);
    if (chat != null) {
      final last = list.isEmpty ? null : list.last;
      await _chats.put(
        chatId,
        chat.copyWith(
          lastMessageText: last?.text ?? '',
          updatedAt: last?.sentAt ?? chat.updatedAt,
        ),
      );
    }
  }

  @override
  Future<String> getDraft(String chatId) async {
    return _drafts.get(chatId) ?? '';
  }

  @override
  Future<void> setDraft(String chatId, String text) async {
    final t = text;
    if (t.isEmpty) {
      await _drafts.delete(chatId);
    } else {
      await _drafts.put(chatId, t);
    }
  }
}