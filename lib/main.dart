import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/chat.dart';
import 'data/models/message.dart';
import 'data/models/user.dart';
import 'data/mock/mock_seed.dart';
import 'data/repositories/hive/hive_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters (manual, no build_runner).
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ChatAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(MessageAdapter());

  // Open boxes.
  await Hive.openBox<User>(HiveKeys.usersBox);
  await Hive.openBox<Chat>(HiveKeys.chatsBox);
  await Hive.openBox<List>(HiveKeys.messagesByChatBox); // List<Message>
  await Hive.openBox<String>(HiveKeys.draftsBox); // chatId -> draft text
  await Hive.openBox(HiveKeys.settingsBox);

  /// NEW: profile storage
  await Hive.openBox('profileBox');

  // Seed mock data on first run.
  await seedIfNeeded();

  runApp(
    const ProviderScope(
      child: MessengerApp(),
    ),
  );
}
