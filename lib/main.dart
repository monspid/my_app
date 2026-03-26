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

  /// 🔥 INIT HIVE
  await Hive.initFlutter();

  /// 🔥 REGISTER ADAPTERS
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ChatAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(MessageAdapter());
  }

  /// 🔥 OPEN ALL BOXES
  await Hive.openBox<User>(HiveKeys.usersBox);
  await Hive.openBox<Chat>(HiveKeys.chatsBox);
  await Hive.openBox<List>(HiveKeys.messagesByChatBox);
  await Hive.openBox<String>(HiveKeys.draftsBox);
  await Hive.openBox(HiveKeys.settingsBox);

  /// ✅ ВАЖНО: PROFILE BOX (ИМЯ ДОЛЖНО СОВПАДАТЬ!)
  final profileBox = await Hive.openBox('profile');

  /// 🧹 FIX: очистка старых кривых данных
  final existingName = profileBox.get('name');
  final existingUsername = profileBox.get('username');

  // если вдруг старый формат (например Map) — чистим
  if (existingName is Map || existingUsername is Map) {
    await profileBox.clear();
  }

  /// 🔥 SEED MOCK DATA
  await seedIfNeeded();

  /// 🚀 RUN APP
  runApp(
    const ProviderScope(
      child: MessengerApp(),
    ),
  );
}