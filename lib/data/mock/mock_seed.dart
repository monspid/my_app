import 'package:hive/hive.dart';

import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../repositories/hive/hive_keys.dart';
import 'mock_users.dart';
import 'mock_chats.dart';
import 'mock_messages.dart';

Future<void> seedIfNeeded() async {
  final usersBox = Hive.box<User>(HiveKeys.usersBox);
  final chatsBox = Hive.box<Chat>(HiveKeys.chatsBox);
  final messagesBox = Hive.box<List>(HiveKeys.messagesByChatBox);

  if (usersBox.isEmpty && chatsBox.isEmpty && messagesBox.isEmpty) {
    final users = mockUsers();
    final chats = mockChats();
    final messagesByChat = mockMessagesByChat();

    for (final u in users) {
      await usersBox.put(u.id, u);
    }

    for (final c in chats) {
      await chatsBox.put(c.id, c);
    }

    for (final entry in messagesByChat.entries) {
      await messagesBox.put(entry.key, entry.value);
    }
  }
}