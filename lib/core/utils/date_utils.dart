import 'package:intl/intl.dart';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

String formatTimeShort(DateTime dt) => DateFormat.Hm().format(dt);

String formatChatTime(DateTime dt) {
  final now = DateTime.now();
  if (isSameDay(dt, now)) return formatTimeShort(dt);

  final yesterday = now.subtract(const Duration(days: 1));
  if (isSameDay(dt, yesterday)) return 'Yesterday';

  return DateFormat('dd MMM').format(dt);
}

String formatDayHeader(DateTime dt) {
  final now = DateTime.now();
  if (isSameDay(dt, now)) return 'Today';

  final yesterday = now.subtract(const Duration(days: 1));
  if (isSameDay(dt, yesterday)) return 'Yesterday';

  return DateFormat('EEE, dd MMM yyyy').format(dt);
}