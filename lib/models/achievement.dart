import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final IconData iconData;
  bool isUnlocked;
  DateTime? unlockedAt;
  final int requiredProgress;
  int currentProgress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.iconData,
    this.isUnlocked = false,
    this.unlockedAt,
    this.requiredProgress = 1,
    this.currentProgress = 0,
  });

  double get progressPercentage {
    if (isUnlocked) return 1.0;
    if (requiredProgress <= 0) return 0.0;
    return (currentProgress / requiredProgress).clamp(0.0, 1.0);
  }
}
