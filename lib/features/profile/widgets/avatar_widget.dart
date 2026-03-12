import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String imageUrl;

  const AvatarWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(imageUrl),
    );
  }
}
