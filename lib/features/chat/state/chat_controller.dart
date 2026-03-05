import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/message.dart';
import '../../../data/repositories/providers.dart';

final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.watchByChat(chatId);
});

final draftProvider = FutureProvider.family<String, String>((ref, chatId) async {
  final repo = ref.read(messageRepositoryProvider);
  return repo.getDraft(chatId);
});

class ReplyState {
  final Message message;
  const ReplyState(this.message);
}

final replyStateProvider = StateProvider.family<ReplyState?, String>((ref, chatId) => null);