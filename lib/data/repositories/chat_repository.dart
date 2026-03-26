import '../models/chat.dart';

abstract class ChatRepository {
  Stream<List<Chat>> watchAll();
  Future<List<Chat>> getAllOnce();
  Future<Chat?> getById(String chatId);

  Future<Chat> createOrGetDirectChat(
    String myUserId,
    String otherUserId,
  );

  Future<void> deleteChat(String chatId);
  Future<void> togglePin(String chatId);
}