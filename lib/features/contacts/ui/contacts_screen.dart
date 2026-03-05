import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/providers.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../state/contacts_controller.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(contactsSearchQueryProvider);
    final userRepo = ref.watch(userRepositoryProvider);
    final myId = ref.watch(currentUserIdProvider);
    final chatRepo = ref.watch(chatRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search contacts...',
              ),
              onChanged: (v) => ref.read(contactsSearchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: userRepo.search(query),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data!
                    .where((u) => u.id != myId) // hide "me"
                    .toList(growable: false);

                if (list.isEmpty) {
                  return EmptyState(
                    icon: query.trim().isEmpty ? Icons.people_outline : Icons.search_off_outlined,
                    title: query.trim().isEmpty ? 'No contacts' : 'No results',
                    subtitle: query.trim().isEmpty
                        ? 'Mock data is empty.'
                        : 'Try a different search query.',
                  );
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final u = list[i];
                    return ListTile(
                      leading: AppAvatar(name: u.name),
                      title: Text(u.name),
                      subtitle: Text(u.isOnline ? 'online' : 'last seen recently'),
                      onTap: () async {
                        final chat = await chatRepo.createOrGetDirectChat(myId, u.id);
                        if (context.mounted) {
                          context.go('/chat/${chat.id}');
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}