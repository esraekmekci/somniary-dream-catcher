import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _notSpecified = 'Not specified';

  final _formKey = GlobalKey<FormState>();

  final _ageRanges = const ['18-24', '25-34', '35-44', '45+'];
  final _genders = const [
    _notSpecified,
    'Female',
    'Male',
    'Non-binary',
    'Prefer not to say',
  ];
  final _relationships = const [
    _notSpecified,
    'Single',
    'In relationship',
    'Married',
    'Complicated',
  ];
  final _occupations = const [
    _notSpecified,
    'Student',
    'Working',
    'Self-employed',
    'Freelancer',
    'Other',
  ];
  final _stress = const [_notSpecified, 'Low', 'Moderate', 'High'];
  final _sleepPatterns = const [
    _notSpecified,
    'Early sleeper',
    'Balanced',
    'Night owl',
    'Irregular',
  ];
  final _zodiacSigns = const [
    _notSpecified,
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  String? _ageRange;
  String _gender = _notSpecified;
  String _relationship = _notSpecified;
  String _occupation = _notSpecified;
  String _stressLevel = 'Moderate';
  String _sleepSchedule = _notSpecified;
  String _zodiacSign = _notSpecified;

  String _pickOption(String? raw, List<String> options, {String? fallback}) {
    final v = raw?.trim();
    if (v != null && options.contains(v)) {
      return v;
    }
    return fallback ?? options.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<AppState>().profile;
    _ageRange = _pickOption(p.ageRange, _ageRanges, fallback: '25-34');
    _gender = _pickOption(p.gender, _genders, fallback: _notSpecified);
    _relationship =
        _pickOption(p.relationship, _relationships, fallback: _notSpecified);
    _occupation =
        _pickOption(p.occupation, _occupations, fallback: _notSpecified);
    _stressLevel = _pickOption(p.stressLevel, _stress, fallback: 'Moderate');
    _sleepSchedule =
        _pickOption(p.sleepSchedule, _sleepPatterns, fallback: _notSpecified);
    _zodiacSign =
        _pickOption(p.zodiacSign, _zodiacSigns, fallback: _notSpecified);
  }

  String? _nullable(String value) => value == _notSpecified ? null : value;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      ageRange: _ageRange,
      gender: _nullable(_gender),
      relationship: _nullable(_relationship),
      occupation: _nullable(_occupation),
      stressLevel: _nullable(_stressLevel),
      sleepSchedule: _nullable(_sleepSchedule),
      zodiacSign: _nullable(_zodiacSign),
    );

    try {
      await context.read<AppState>().saveProfile(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = appState.user?.email ?? 'unknown@email.com';
    final userName = email.split('@').first;
    final initial = userName.isEmpty ? 'S' : userName[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Space')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppPalette.color700 : AppPalette.color200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              color: isDark
                                  ? AppPalette.darkTextSecondary
                                  : AppPalette.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: (isDark
                                      ? AppPalette.color700
                                      : AppPalette.color200)
                                  .withValues(alpha: 0.35),
                            ),
                            child: Text(
                                appState.isPremium ? 'Premium' : 'Free plan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About You · Memory Context',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'These preferences personalize your interpretations. Stored locally and never used for advertising.',
                      style: TextStyle(
                        color: isDark
                            ? AppPalette.darkTextSecondary
                            : AppPalette.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _dropdownField(
                      label: 'Age range *',
                      value: _ageRange,
                      options: _ageRanges,
                      onChanged: (v) => setState(() => _ageRange = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    _dropdownField(
                      label: 'Gender',
                      value: _gender,
                      options: _genders,
                      onChanged: (v) =>
                          setState(() => _gender = v ?? _notSpecified),
                    ),
                    _dropdownField(
                      label: 'Relationship status',
                      value: _relationship,
                      options: _relationships,
                      onChanged: (v) =>
                          setState(() => _relationship = v ?? _notSpecified),
                    ),
                    _dropdownField(
                      label: 'Occupation',
                      value: _occupation,
                      options: _occupations,
                      onChanged: (v) =>
                          setState(() => _occupation = v ?? _notSpecified),
                    ),
                    _dropdownField(
                      label: 'Current stress level',
                      value: _stressLevel,
                      options: _stress,
                      onChanged: (v) =>
                          setState(() => _stressLevel = v ?? _notSpecified),
                    ),
                    _dropdownField(
                      label: 'Sleep pattern',
                      value: _sleepSchedule,
                      options: _sleepPatterns,
                      onChanged: (v) =>
                          setState(() => _sleepSchedule = v ?? _notSpecified),
                    ),
                    _dropdownField(
                      label: 'Zodiac sign',
                      value: _zodiacSign,
                      options: _zodiacSigns,
                      onChanged: (v) =>
                          setState(() => _zodiacSign = v ?? _notSpecified),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded),
                        const SizedBox(width: 8),
                        Text(
                          'Somniary Premium',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                        'Unlimited interpretations · Voice input · Memory'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Premium management yakında.')),
                          );
                        },
                        child: const Text('Explore Premium'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _themeTile(
                          label: 'Dark',
                          icon: Icons.nightlight_round,
                          active: appState.themeMode == ThemeMode.dark,
                          onTap: () => context
                              .read<AppState>()
                              .setThemeMode(ThemeMode.dark),
                        ),
                        const SizedBox(width: 8),
                        _themeTile(
                          label: 'Light',
                          icon: Icons.wb_sunny_outlined,
                          active: appState.themeMode == ThemeMode.light,
                          onTap: () => context
                              .read<AppState>()
                              .setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(width: 8),
                        _themeTile(
                          label: 'System',
                          icon: Icons.desktop_windows_outlined,
                          active: appState.themeMode == ThemeMode.system,
                          onTap: () => context
                              .read<AppState>()
                              .setThemeMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: isDark
                              ? AppPalette.color200
                              : AppPalette.color700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Privacy',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your dreams and interpretations are private by default. We never sell your data, use it for advertising, or share it with third parties. You can delete all your data at any time from Settings.',
                      style: TextStyle(
                        height: 1.5,
                        color: isDark
                            ? AppPalette.darkTextSecondary
                            : AppPalette.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('Save Preferences'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: appState.signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: value,
        isExpanded: true,
        menuMaxHeight: 260,
        itemHeight: 48,
        items: options
            .map(
              (v) => DropdownMenuItem(
                value: v,
                child: Text(v, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _themeTile({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? AppPalette.color500
                  : AppPalette.color300.withValues(alpha: 0.5),
            ),
            color: active
                ? AppPalette.color100.withValues(alpha: 0.25)
                : Colors.transparent,
          ),
          child: Column(
            children: [
              Icon(icon, size: 18),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
