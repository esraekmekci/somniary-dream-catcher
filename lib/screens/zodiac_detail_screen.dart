import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/profile_utils.dart';
import '../models/zodiac_sign.dart';
import '../services/zodiac_service.dart';
import '../widgets/mystic_background.dart';

class ZodiacDetailScreen extends StatefulWidget {
  const ZodiacDetailScreen({super.key, required this.zodiacName});

  final String zodiacName;

  @override
  State<ZodiacDetailScreen> createState() => _ZodiacDetailScreenState();
}

class _ZodiacDetailScreenState extends State<ZodiacDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  late final Future<ZodiacSign?> _future;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _future =
        ZodiacService(FirebaseFirestore.instance).getZodiacSign(widget.zodiacName);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = zodiacSymbol(widget.zodiacName);

    return MysticBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.zodiacName),
        ),
        body: FutureBuilder<ZodiacSign?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final sign = snapshot.data;
            if (sign == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Zodiac details are not available yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppPalette.darkTextSecondary
                              : AppPalette.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // --- Glowing symbol ---
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppPalette.color400
                                  .withValues(alpha: 0.25 * _glowAnimation.value),
                              AppPalette.color700
                                  .withValues(alpha: 0.08 * _glowAnimation.value),
                              Colors.transparent,
                            ],
                            stops: const [0.3, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppPalette.color400
                                  .withValues(alpha: 0.3 * _glowAnimation.value),
                              blurRadius: 40 * _glowAnimation.value,
                              spreadRadius: 8 * _glowAnimation.value,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          sign.symbol,
                          style: TextStyle(
                            fontSize: 80,
                            color: isDark
                                ? AppPalette.color200
                                : AppPalette.color700,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // --- Name ---
                  Text(
                    sign.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  // --- Date range ---
                  Text(
                    sign.dateRange,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppPalette.darkTextSecondary
                          : AppPalette.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // --- Element badge ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: _elementColor(sign.element, isDark)
                          .withValues(alpha: 0.18),
                      border: Border.all(
                        color: _elementColor(sign.element, isDark)
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _elementEmoji(sign.element),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sign.element,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _elementColor(sign.element, isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // --- Description card ---
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.spa_rounded,
                                size: 20,
                                color: isDark
                                    ? AppPalette.color300
                                    : AppPalette.color600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'General Characteristics',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            sign.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.7,
                              color: isDark
                                  ? AppPalette.darkTextPrimary
                                  : AppPalette.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _elementColor(String element, bool isDark) {
    switch (element) {
      case 'Fire':
        return isDark ? const Color(0xFFFF8A65) : const Color(0xFFE64A19);
      case 'Earth':
        return isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32);
      case 'Air':
        return isDark ? const Color(0xFF90CAF9) : const Color(0xFF1565C0);
      case 'Water':
        return isDark ? const Color(0xFF80DEEA) : const Color(0xFF00838F);
      default:
        return AppPalette.color400;
    }
  }

  String _elementEmoji(String element) {
    switch (element) {
      case 'Fire':
        return '🔥';
      case 'Earth':
        return '🌍';
      case 'Air':
        return '💨';
      case 'Water':
        return '💧';
      default:
        return '✨';
    }
  }
}
