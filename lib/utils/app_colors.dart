import 'package:flutter/material.dart';

class AppColors {
  // Designjoy-inspired primary colors
  static const Color primary = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFF9127FF);
  static const Color accent = Color(0xFF097FFF);

  // Pink/Magenta accent (Designjoy style)
  static const Color pink = Color(0xFFFF6B9D);
  static const Color magenta = Color(0xFF9127FF);
  static const Color blue = Color(0xFF097FFF);
  static const Color orange = Color(0xFFFF8E53);
  static const Color yellow = Color(0xFFFFCE45);
  static const Color green = Color(0xFF38EF7D);

  // Gradient colors - Designjoy style colorful cards
  static const Color gradientPinkStart = Color(0xFFFF6B9D);
  static const Color gradientPinkEnd = Color(0xFFFF8E53);

  static const Color gradientBlueStart = Color(0xFF667EEA);
  static const Color gradientBlueEnd = Color(0xFF764BA2);

  static const Color gradientGreenStart = Color(0xFF11998E);
  static const Color gradientGreenEnd = Color(0xFF38EF7D);

  static const Color gradientOrangeStart = Color(0xFFFF6B35);
  static const Color gradientOrangeEnd = Color(0xFFFFCE45);

  static const Color gradientYellowStart = Color(0xFFFFCE45);
  static const Color gradientYellowEnd = Color(0xFFFF8E53);

  // Text colors - Clean and minimal
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Background colors - Light and airy
  static const Color background = Color(0xFFF5F5F7);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF1A1A2E);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Designjoy-style gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF2D2D44)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [gradientPinkStart, gradientPinkEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [gradientBlueStart, gradientBlueEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [gradientGreenStart, gradientGreenEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [gradientOrangeStart, gradientOrangeEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [gradientYellowStart, gradientYellowEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Colorful multi-color gradient (Designjoy smiley cards style)
  static const LinearGradient multiColorGradient = LinearGradient(
    colors: [
      Color(0xFFFF6B9D),
      Color(0xFFFF8E53),
      Color(0xFFFFCE45),
      Color(0xFF38EF7D),
      Color(0xFF097FFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
