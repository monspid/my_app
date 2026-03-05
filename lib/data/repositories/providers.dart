import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_repository.dart';
import 'chat_repository.dart';
import 'message_repository.dart';
import 'hive/hive_user_repository.dart';
import 'hive/hive_chat_repository.dart';
import 'hive/hive_message_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => HiveUserRepository());
final chatRepositoryProvider = Provider<ChatRepository>((ref) => HiveChatRepository());
final messageRepositoryProvider = Provider<MessageRepository>((ref) => HiveMessageRepository());

/// For prototype, current user is always u_me from mocks.
final currentUserIdProvider = Provider<String>((ref) => 'u_me');