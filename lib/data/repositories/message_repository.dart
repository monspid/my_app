import '../models/message.dart';

abstract class MessageRepository {
  Stream<List<Message>> watchByChat(String chatId);
  Future<List<Message>> getByChatOnce(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? replyToMessageId,
  });

  Future<void> deleteMessage(String chatId, String messageId);

  Future<String> getDraft(String chatId);
  Future<void> setDraft(String chatId, String text);
}