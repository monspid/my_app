import 'package:hive/hive.dart';

import '../../models/message.dart';
import '../message_repository.dart';
import '../hive/hive_keys.dart';

class HiveMessageRepository implements MessageRepository {

  @override
  Stream<List<Message>> watchByChat(String chatId) async* {
    yield await getMessages(chatId);
  }

  @override
  Future<List<Message>> getByChatOnce(String chatId) {
    return getMessages(chatId);
  }

  @override
  Future<List<Message>> getMessages(String chatId) async {
    final box = Hive.box(HiveKeys.messagesByChatBox);

    final raw = box.get(chatId);

    if (raw == null) return [];

    final list = (raw as List).cast<Message>();

    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));

    return list;
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? replyToMessageId,
  }) async {

    final box = Hive.box(HiveKeys.messagesByChatBox);

    final raw = box.get(chatId);

    final List<Message> messages =
        raw != null ? (raw as List).cast<Message>() : [];

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: senderId,
      text: text,
      sentAt: DateTime.now(),
      replyToMessageId: replyToMessageId,
    );

    messages.add(message);

    await box.put(chatId, messages);
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    final box = Hive.box(HiveKeys.messagesByChatBox);

    final raw = box.get(chatId);
    if (raw == null) return;

    final List<Message> messages = (raw as List).cast<Message>();

    messages.removeWhere((m) => m.id == messageId);

    await box.put(chatId, messages);
  }

  @override
  Future<String> getDraft(String chatId) async {
    final box = Hive.box(HiveKeys.draftsBox);
    return box.get(chatId, defaultValue: '');
  }

  @override
  Future<void> setDraft(String chatId, String text) async {
    final box = Hive.box(HiveKeys.draftsBox);
    await box.put(chatId, text);
  }
}