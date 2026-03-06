import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../models/dream_entry.dart';
import '../services/dreams_service.dart';
import '../state/app_state.dart';
import '../widgets/mystic_background.dart';

class JournalDetailScreen extends StatelessWidget {
  const JournalDetailScreen({super.key, required this.dreamId});

  final String dreamId;

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

  String _titleFor(DreamEntry d) {
    if (d.autoTitle.trim().isNotEmpty) return d.autoTitle.trim();
    return 'Untitled Dream';
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AppState>().user!.uid;
    final service = DreamsService(FirebaseFirestore.instance);
    final date = DateFormat('MMM d, y · h:mm a');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MysticBackground(
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<DreamEntry?>(
            stream: service.watchDream(uid, dreamId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final dream = snapshot.data;
              if (dream == null) {
                return const Center(child: Text('Dream not found.'));
              }

              final mood = dream.primaryMood.trim().isEmpty
                  ? 'Curious'
                  : dream.primaryMood;
              final moodColor = _moodColor(mood, isDark);

              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 26),
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: isDark
                                ? AppPalette.color200
                                : AppPalette.color700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Journal',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppPalette.color200
                                  : AppPalette.color700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _titleFor(dream),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          date.format(dream.createdAt),
                          style: TextStyle(
                            color: isDark
                                ? AppPalette.darkTextSecondary
                                : AppPalette.lightTextSecondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: moodColor.withValues(alpha: 0.16),
                          border: Border.all(
                              color: moodColor.withValues(alpha: 0.45)),
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
                  const SizedBox(height: 16),
                  _blockCard(
                    context,
                    child: Text(
                      dream.dreamText,
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.65,
                        color:
                            isDark ? AppPalette.color100 : AppPalette.color900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _blockCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppPalette.color800
                                    : AppPalette.color100,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Icon(
                                Icons.nights_stay_rounded,
                                size: 18,
                                color: isDark
                                    ? AppPalette.color100
                                    : AppPalette.color700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI Interpretation',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          dream.interpretationText,
                          style: TextStyle(
                            fontSize: 19,
                            height: 1.65,
                            color: isDark
                                ? AppPalette.color100
                                : AppPalette.color900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _chipSection(
                    context,
                    title: 'Symbols',
                    icon: Icons.sell_outlined,
                    values: dream.symbols,
                  ),
                  const SizedBox(height: 16),
                  _chipSection(
                    context,
                    title: 'Themes',
                    icon: Icons.auto_awesome_outlined,
                    values: dream.themes,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _blockCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppPalette.darkSurface.withValues(alpha: 0.92)
            : AppPalette.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppPalette.color700.withValues(alpha: 0.35)
              : AppPalette.color200,
        ),
      ),
      child: child,
    );
  }

  Widget _chipSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> values,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppPalette.color200 : AppPalette.color700,
            ),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (values.isEmpty ? ['-'] : values).map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: isDark
                    ? AppPalette.color800.withValues(alpha: 0.42)
                    : AppPalette.color100,
                border: Border.all(
                  color: isDark
                      ? AppPalette.color700.withValues(alpha: 0.45)
                      : AppPalette.color200,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: isDark ? AppPalette.color200 : AppPalette.color700,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
