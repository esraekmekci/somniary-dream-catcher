import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../models/dream_entry.dart';
import '../services/dreams_service.dart';
import '../state/app_state.dart';
import 'journal_detail_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  static const _symbolIcons = {
    'yılan': Icons.waves_outlined,
    'su': Icons.water_drop_outlined,
    'uçmak': Icons.air_rounded,
    'düşmek': Icons.south_rounded,
    'diş': Icons.mood_bad_outlined,
    'ölüm': Icons.hourglass_bottom_outlined,
    'bebek': Icons.child_care_outlined,
    'ev': Icons.home_outlined,
    'merdiven': Icons.stairs_outlined,
    'kapı': Icons.door_front_door_outlined,
    'ayna': Icons.flip_to_front_outlined,
  };

  static const _themeMood = {
    'calm': 'Calm',
    'peace': 'Calm',
    'huzur': 'Calm',
    'fear': 'Anxious',
    'anxiety': 'Anxious',
    'kaygı': 'Anxious',
    'panic': 'Anxious',
    'exploration': 'Curious',
    'curiosity': 'Curious',
    'mystery': 'Curious',
    'discovery': 'Curious',
  };

  String _autoTitle(DreamEntry d) {
    if (d.autoTitle.trim().isNotEmpty) return d.autoTitle.trim();
    final symbol = d.symbols.isNotEmpty ? d.symbols.first : '';
    final theme = d.themes.isNotEmpty ? d.themes.first : '';
    if (symbol.isNotEmpty) {
      return symbol[0].toUpperCase() + symbol.substring(1);
    }
    if (theme.isNotEmpty) {
      return theme[0].toUpperCase() + theme.substring(1);
    }
    final words = d.dreamText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(3)
        .toList();
    if (words.isEmpty) return 'Untitled Dream';
    return words.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  String _mood(DreamEntry d) {
    if (d.primaryMood.trim().isNotEmpty) return d.primaryMood;
    final source = d.themes.join(' ').toLowerCase();
    for (final e in _themeMood.entries) {
      if (source.contains(e.key)) return e.value;
    }
    return 'Curious';
  }

  Color _moodColor(String mood, bool isDark) {
    switch (mood.toLowerCase()) {
      case 'anxious':
        return isDark ? const Color(0xFFA4586E) : const Color(0xFFD8839C);
      case 'calm':
      case 'peaceful':
        return isDark ? const Color(0xFF4E8C7E) : const Color(0xFF67A998);
      default:
        return isDark ? AppPalette.color500 : AppPalette.color600;
    }
  }

  IconData _iconFor(DreamEntry d) {
    for (final s in d.symbols) {
      final found = _symbolIcons[s.toLowerCase()];
      if (found != null) return found;
    }
    return Icons.nights_stay_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final service = DreamsService(FirebaseFirestore.instance);
    final date = DateFormat('MMM d, y');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Dream Journal')),
      body: StreamBuilder<List<DreamEntry>>(
        stream: service.watchDreams(appState.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final dreams = snapshot.data ?? [];
          if (dreams.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No dreams recorded yet.',
                  style: TextStyle(
                    color: isDark
                        ? AppPalette.darkTextSecondary
                        : AppPalette.lightTextSecondary,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 22),
            itemCount: dreams.length,
            itemBuilder: (context, index) {
              final d = dreams[index];
              final mood = _mood(d);
              final moodColor = _moodColor(mood, isDark);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: 2,
                                color: index == 0
                                    ? Colors.transparent
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.08)),
                              ),
                            ),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppPalette.color800
                                    : AppPalette.color100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: moodColor.withValues(alpha: 0.7),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _iconFor(d),
                                size: 15,
                                color: isDark
                                    ? AppPalette.color100
                                    : AppPalette.color700,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2,
                                color: index == dreams.length - 1
                                    ? Colors.transparent
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.08)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  JournalDetailScreen(dreamId: d.id),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppPalette.darkSurface
                                      .withValues(alpha: 0.92)
                                  : AppPalette.lightSurface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? AppPalette.color700
                                        .withValues(alpha: 0.35)
                                    : AppPalette.color200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        date.format(d.createdAt),
                                        style: TextStyle(
                                          color: isDark
                                              ? AppPalette.darkTextSecondary
                                              : AppPalette.lightTextSecondary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(99),
                                        color:
                                            moodColor.withValues(alpha: 0.16),
                                        border: Border.all(
                                            color: moodColor.withValues(
                                                alpha: 0.45)),
                                      ),
                                      child: Text(
                                        mood,
                                        style: TextStyle(
                                          color: moodColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _autoTitle(d),
                                  style: Theme.of(context).textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  d.dreamText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1.5,
                                    color: isDark
                                        ? AppPalette.darkTextSecondary
                                        : AppPalette.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: d.themes.take(3).map((t) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(99),
                                        color: isDark
                                            ? AppPalette.color800
                                                .withValues(alpha: 0.36)
                                            : AppPalette.color100,
                                      ),
                                      child: Text(
                                        t,
                                        style: TextStyle(
                                          color: isDark
                                              ? AppPalette.color200
                                              : AppPalette.color700,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
