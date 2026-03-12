import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String name;
  final String username;
  final String bio;

  const ProfileInfo({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "@$username",
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          bio,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
