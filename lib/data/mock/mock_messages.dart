import '../models/message.dart';

Map<String, List<Message>> mockMessagesByChat() {
  final now = DateTime.now();

  return {
    'c_1': [
      Message(
        id: 'm_1',
        chatId: 'c_1',
        senderId: 'u_1',
        text: 'Hey! Are we still on for later?',
        sentAt: now.subtract(const Duration(hours: 3)),
      ),
      Message(
        id: 'm_2',
        chatId: 'c_1',
        senderId: 'u_me',
        text: 'Yes 🙂',
        sentAt: now.subtract(const Duration(hours: 2, minutes: 50)),
      ),
      Message(
        id: 'm_3',
        chatId: 'c_1',
        senderId: 'u_1',
        text: 'See you today?',
        sentAt: now.subtract(const Duration(minutes: 5)),
      ),
    ],
    'c_2': [
      Message(
        id: 'm_4',
        chatId: 'c_2',
        senderId: 'u_2',
        text: 'Can you send the notes?',
        sentAt: now.subtract(const Duration(hours: 6)),
      ),
      Message(
        id: 'm_5',
        chatId: 'c_2',
        senderId: 'u_me',
        text: 'Sure, one moment.',
        sentAt: now.subtract(const Duration(hours: 5, minutes: 40)),
      ),
      Message(
        id: 'm_6',
        chatId: 'c_2',
        senderId: 'u_me',
        text: 'Got it, thanks!',
        sentAt: now.subtract(const Duration(hours: 2)),
      ),
    ],
    'c_3': [
      Message(
        id: 'm_7',
        chatId: 'c_3',
        senderId: 'u_3',
        text: 'Are you free this week?',
        sentAt: now.subtract(const Duration(days: 2, hours: 2)),
      ),
      Message(
        id: 'm_8',
        chatId: 'c_3',
        senderId: 'u_me',
        text: 'Friday works.',
        sentAt: now.subtract(const Duration(days: 2, hours: 2, minutes: 10)),
      ),
      Message(
        id: 'm_9',
        chatId: 'c_3',
        senderId: 'u_3',
        text: 'Let’s sync tomorrow.',
        sentAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
    ],
  };
}