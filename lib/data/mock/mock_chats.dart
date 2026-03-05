import '../models/chat.dart';

List<Chat> mockChats() {
  final now = DateTime.now();
  return [
    Chat(
      id: 'c_1',
      participantIds: const ['u_me', 'u_1'],
      pinned: true,
      unreadCount: 2,
      lastMessageText: 'See you today?',
      updatedAt: now.subtract(const Duration(minutes: 5)),
    ),
    Chat(
      id: 'c_2',
      participantIds: const ['u_me', 'u_2'],
      pinned: false,
      unreadCount: 0,
      lastMessageText: 'Got it, thanks!',
      updatedAt: now.subtract(const Duration(hours: 2)),
    ),
    Chat(
      id: 'c_3',
      participantIds: const ['u_me', 'u_3'],
      pinned: false,
      unreadCount: 5,
      lastMessageText: 'Let’s sync tomorrow.',
      updatedAt: now.subtract(const Duration(days: 1, hours: 1)),
    ),
  ];
}