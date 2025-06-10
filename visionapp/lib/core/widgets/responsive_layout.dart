import 'package:flutter/material.dart';
import 'package:visionapp/core/utils/responsive_helper.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isDesktop(context)) {
          return desktop;
        }
        if (ResponsiveHelper.isTablet(context)) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}