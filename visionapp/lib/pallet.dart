import 'package:flutter/material.dart';

class Palette {
  // Primary brand colors
  static const Color primaryColor = Color(0xFF6200EE); // Deep purple for main actions, buttons
  static const Color primaryDarkColor = Color(0xFF3700B3); // Darker purple variant
  static const Color primaryLightColor = Color(0xFFBB86FC); // Lighter purple variant
  static const Color accentColor = Color(0xFF03DAC5); // Teal accent for highlights

  // Background colors
  static const Color backgroundColor = Color(0xFFF6F6F6); // Light gray background
  static const Color cardColor = Color(0xFFFFFFFF); // White for cards and containers
  static const Color dividerColor = Color(0xFFE0E0E0); // Light gray for dividers

  // Text colors
  static const Color primaryTextColor = Color(0xFF212121); // Dark gray for main text
  static const Color secondaryTextColor = Color(0xFF757575); // Medium gray for secondary text
  static const Color tertiaryTextColor = Color(0xFF9E9E9E); // Light gray for tertiary text
  static const Color inverseTextColor = Color(0xFFFFFFFF); // White text for dark backgrounds

  // Status colors
  static const Color urgentColor = Color(0xFFFF5252); // Red for urgent status
  static const Color highPriorityColor = Color(0xFFFFB300); // Amber for high priority
  static const Color standardColor = Color(0xFF4CAF50); // Green for standard/normal
  static const Color queuedColor = Color(0xFF2196F3); // Blue for queued status
  static const Color inProductionColor = Color(0xFF4CAF50); // Green for in production

  // Order status indicator colors
  static const Color urgentIndicator = Color(0xFFFF5252); // Red bar
  static const Color highPriorityIndicator = Color(0xFFFFB300); // Yellow bar
  static const Color standardIndicator = Color(0xFF4CAF50); // Green bar

  // Button colors
  static const Color buttonPrimaryColor = Color(0xFF6200EE); // Purple for primary buttons
  static const Color buttonSecondaryColor = Color(0xFFE0E0E0); // Light gray for secondary buttons
  static const Color buttonDisabledColor = Color(0xFFBDBDBD); // Medium gray for disabled buttons
  
  // Input field colors
  static const Color inputBorderColor = Color(0xFFE0E0E0); // Light gray for borders
  static const Color inputFocusColor = Color(0xFF6200EE); // Purple for focused inputs
  static const Color inputErrorColor = Color(0xFFB00020); // Error red
  
  // Navigation colors
  static const Color activeNavColor = Color(0xFF6200EE); // Purple for active nav items
  static const Color inactiveNavColor = Color(0xFF9E9E9E); // Gray for inactive nav items
  
  // Tab colors
  static const Color activeTabColor = Color(0xFF6200EE); // Purple for active tab
  static const Color inactiveTabColor = Color(0xFF757575); // Gray for inactive tabs
  
  // Common UI colors
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  static const Color transparentColor = Colors.transparent;
  
  // Add New Order form colors
  static const Color formLabelColor = Color(0xFF424242); // Dark gray for form labels
  static const Color formBorderColor = Color(0xFFE0E0E0); // Light gray for form borders
  
  // Priority slider colors
  static const Color priorityStandardColor = Color(0xFFE8F5E9); // Light green background
  static const Color priorityHighColor = Color(0xFFFFF8E1); // Light amber background
  static const Color priorityUrgentColor = Color(0xFFFFEBEE); // Light red background
}