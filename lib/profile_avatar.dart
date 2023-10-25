import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.avatar,
    this.radius = 20,
    Key? key,
  }) : super(key: key);

  final String avatar;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).cardColor,
        child: ClipOval(
          child: Image.asset(
            avatar,
            package: 'assets',
            height: 42,
            width: 42,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}