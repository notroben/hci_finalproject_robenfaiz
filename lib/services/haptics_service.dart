import 'package:flutter/services.dart';

class HapticsService {
  // Low-intensity trigger for step changes/light ticks
  static Future<void> triggerLight() async {
    await HapticFeedback.lightImpact();
  }

  // Medium-intensity trigger for button triggers
  static Future<void> triggerMedium() async {
    await HapticFeedback.mediumImpact();
  }

  // Strong notification haptic pulse
  static Future<void> triggerHeavy() async {
    await HapticFeedback.heavyImpact();
  }

  // Multi-pulse haptic cue for task/routine success feedback
  static Future<void> triggerSuccessPattern() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }
}
