import 'package:hive/hive.dart';

import '../../models/chat.dart';
import '../chat_repository.dart';
import '../hive/hive_keys.dart';

class HiveChatRepository implements ChatRepository {

  @override
  Stream<List<Chat>> watchAll() async* {
    final box = Hive.box<Chat>(HiveKeys.chatsBox);
    yield box.values.toList();
  }

  @override
  Future<List<Chat>> getAllOnce() async {
    final box = Hive.box<Chat>(HiveKeys.chatsBox);
    return box.values.toList();
  }

  @override
  Future<Chat?> getById(String chatId) async {
    final box = Hive.box<Chat>(HiveKeys.chatsBox);
    return box.get(chatId);
  }

  @override
  Future<Chat> createOrGetDirectChat(
    String myUserId,
    String otherUserId,
  ) async {

    final box = Hive.box<Chat>(HiveKeys.chatsBox);

    for (final chat in box.values) {
      if (chat.participantIds.contains(myUserId) &&
          chat.participantIds.contains(otherUserId)) {
        return chat;
      }
    }

    final chat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      participantIds: [myUserId, otherUserId],
    );

    await box.put(chat.id, chat);

    return chat;
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final box = Hive.box<Chat>(HiveKeys.chatsBox);
    await box.delete(chatId);
  }

  @override
  Future<void> togglePin(String chatId) async {
    // временно пусто (чтобы не было ошибок)
  }
}