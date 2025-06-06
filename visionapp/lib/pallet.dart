import 'package:flutter/material.dart';

class Palette {
  // Primary brand colors
  static const Color primaryBlue = Color(0xFF1E40AF); // Main blue
  static const Color secondaryBlue = Color(0xFF3B82F6); // Secondary blue
  static const Color lightBlue = Color(0xFFF8FAFC); // Light blue background

  // Background colors
  static const Color backgroundColor = Color(0xFF1E3A8A); // Dark blue background
  static const Color cardBackground = Color(0xFFFFFFFF); // White for cards
  static const Color surfaceGray = Color(0xFFF8FAFC); // Light gray surface
  static const Color borderColor = Color(0xFFE2E8F0); // Border color
  static const Color dividerColor = Color(0xFFF1F5F9); // Divider color

  // Text colors
  static const Color primaryTextColor = Color(0xFF111827); // Dark text
  static const Color secondaryTextColor = Color(0xFF6B7280); // Secondary text
  static const Color tertiaryTextColor = Color(0xFF64748B); // Tertiary text
  static const Color inverseTextColor = Color(0xFFFFFFFF); // White text

  // Status colors
  static const Color urgentColor = Color(0xFFDC2626); // Red for urgent priority
  static const Color highPriorityColor = Color(0xFFFACC15); // Yellow for high priority
  static const Color normalPriorityColor = Color(0xFF22C55E); // Green for normal priority

  // Order status colors
  static const Color inProductionColor = Color(0xFF059669); // Green for in production
  static const Color queuedColor = Color(0xFF1E40AF); // Blue for queued
  static const Color completedColor = Color(0xFF4B5563); // Gray for completed
  static const Color pausedColor = Color(0xFFD97706); // Orange for paused

  // Shadow colors
  static const Color shadowColor = Color(0xFF1E40AF); // Used with opacity for shadows
  
  // Navigation colors
  static const Color activeNavColor = Color(0xFF1E40AF); // Active navigation item
  static const Color inactiveNavColor = Color(0xFF64748B); // Inactive navigation item

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF3B82F6),
    Color(0xFF1E40AF),
  ];

  static const List<Color> buttonGradient = [
    Color(0xFF1E40AF),
    Color(0xFF3B82F6),
  ];

  // Common UI colors
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color transparentColor = Colors.transparent;

  // Helper method to get shadow
  static List<BoxShadow> getShadow({double opacity = 0.04}) {
    return [
      BoxShadow(
        color: shadowColor.withOpacity(opacity),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // Helper method to get button shadow
  static List<BoxShadow> getButtonShadow({double opacity = 0.3}) {
    return [
      BoxShadow(
        color: shadowColor.withOpacity(opacity),
        blurRadius: 12,
        offset: const Offset(0, 12),
      ),
    ];
  }
}