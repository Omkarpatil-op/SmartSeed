import 'package:flutter/material.dart';

class Level {
  final int id;
  final String name;
  final String icon;
  bool isUnlocked;
  final Offset position;

  Level({
    required this.id,
    required this.name,
    required this.icon,
    required this.isUnlocked,
    required this.position,
  });
}
