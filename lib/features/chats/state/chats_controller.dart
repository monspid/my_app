import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/chat.dart';
import '../../../data/repositories/providers.dart';

final chatsStreamProvider = StreamProvider<List<Chat>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchAll();
});

final chatsSearchQueryProvider = StateProvider<String>((ref) => '');