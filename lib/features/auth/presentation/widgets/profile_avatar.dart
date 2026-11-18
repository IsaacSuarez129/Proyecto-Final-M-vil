import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 24,
  });

  final String name;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;

    return CircleAvatar(
      radius: radius,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null ? Text(name.substring(0, 1).toUpperCase()) : null,
    );
  }
}