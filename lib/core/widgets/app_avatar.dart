import 'package:flutter/material.dart';
import '../utils/initials.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.secondaryContainer,
      foregroundColor: cs.onSecondaryContainer,
      child: Text(
        initialsFromName(name),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.8),
      ),
    );
  }
}