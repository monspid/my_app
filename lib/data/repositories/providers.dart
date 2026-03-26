import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_repository.dart';
import 'message_repository.dart';

import 'hive/hive_chat_repository.dart';
import 'hive/hive_message_repository.dart';

final chatRepositoryProvider =
    Provider<ChatRepository>((ref) => HiveChatRepository());

final messageRepositoryProvider =
    Provider<MessageRepository>((ref) => HiveMessageRepository());