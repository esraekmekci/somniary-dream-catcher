import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../widgets/mystic_background.dart';
import 'chat_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'symbol_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      ChatScreen(),
      JournalScreen(),
      SymbolSearchScreen(),
      ProfileScreen(),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MysticBackground(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(child: IndexedStack(index: _index, children: pages)),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppPalette.color900 : AppPalette.lightSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? AppPalette.color700.withValues(alpha: 0.35)
                      : AppPalette.color200,
                ),
              ),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    active: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                  _TabButton(
                    label: 'Journal',
                    icon: Icons.menu_book_rounded,
                    active: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                  _TabButton(
                    label: 'Symbols',
                    icon: Icons.auto_awesome_outlined,
                    active: _index == 2,
                    onTap: () => setState(() => _index = 2),
                  ),
                  _TabButton(
                    label: 'Profile',
                    icon: Icons.person_outline_rounded,
                    active: _index == 3,
                    onTap: () => setState(() => _index = 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: active
                ? (isDark ? AppPalette.color800 : AppPalette.color100)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? (isDark ? AppPalette.color100 : AppPalette.color700)
                    : (isDark
                        ? AppPalette.darkTextSecondary
                        : AppPalette.lightTextSecondary),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? (isDark ? AppPalette.color100 : AppPalette.color700)
                        : (isDark
                            ? AppPalette.darkTextSecondary
                            : AppPalette.lightTextSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
