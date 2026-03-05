String initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';

  String firstLetter(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase();
  }

  if (parts.length == 1) {
    final s = parts.first;
    if (s.length == 1) return firstLetter(s);
    return (s[0] + s[1]).toUpperCase();
  }

  final first = firstLetter(parts.first);
  final last = firstLetter(parts.last);
  return (first + last).toUpperCase();
}