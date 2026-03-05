import '../models/user.dart';

List<User> mockUsers() {
  final now = DateTime.now();
  return [
    User(id: 'u_me', name: 'You', isOnline: true, lastSeenAt: now),
    User(id: 'u_1', name: 'Aigerim S.', isOnline: true, lastSeenAt: now),
    User(id: 'u_2', name: 'Daniyar K.', isOnline: false, lastSeenAt: now.subtract(const Duration(minutes: 12))),
    User(id: 'u_3', name: 'Madi M.', isOnline: false, lastSeenAt: now.subtract(const Duration(hours: 3))),
    User(id: 'u_4', name: 'Zarina A.', isOnline: true, lastSeenAt: now),
    User(id: 'u_5', name: 'Timur R.', isOnline: false, lastSeenAt: now.subtract(const Duration(days: 1, hours: 2))),
  ];
}