import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

class MysticBackground extends StatelessWidget {
  const MysticBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? AppPalette.darkBackground : AppPalette.lightBackground,
      child: child,
    );
  }
}
