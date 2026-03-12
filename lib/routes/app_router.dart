import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/chats/ui/chats_screen.dart';
import '../features/profile/ui/profile_screen.dart';
import '../features/chat/ui/chat_screen.dart';
import '../features/contacts/ui/contacts_screen.dart';
import '../features/settings/ui/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chats',
    routes: [
      /// Chats
      GoRoute(
        path: '/chats',
        name: 'chats',
        builder: (context, state) => const ChatsScreen(),
      ),

      /// Chat dialog
      GoRoute(
        path: '/chat/:chatId',
        name: 'chat',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatScreen(chatId: chatId);
        },
      ),

      /// Contacts
      GoRoute(
        path: '/contacts',
        name: 'contacts',
        builder: (context, state) => const ContactsScreen(),
      ),

      /// Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      /// Profile  ← добавили
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Text(
            state.error.toString(),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    },
  );
});

GoRouter routerOf(BuildContext context) => GoRouter.of(context);
