import 'package:flutter/material.dart';

class AppColors {
  static const LinearGradient appBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF6AFCA7),
      Color(0xFF05E672),
      Color(0xFF03351B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primary = Color(0xFF0D5C46);
  static const Color primaryDark = Color(0xFF005036);
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color badgeGreen = Color(0xFFE6F4EA);
  static const Color textDark = Color(0xFF11281F);
  static const Color textBody = Color(0xFF333333);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtitle = Color(0xFF3B5449);
  static const Color textDesc = Color(0xFF4A6358);
  static const Color border = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFE11D48);
}