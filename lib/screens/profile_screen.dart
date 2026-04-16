import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/profile_utils.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../widgets/birth_date_picker_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _notSpecified = 'Not specified';

  final _formKey = GlobalKey<FormState>();
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
  final _stressOptions = const ['Calm', 'Balanced', 'Tense', 'Overloaded'];
  final _stressEmojis = const ['😌', '🙂', '😣', '😤'];
  final _sleepOptions = const [
    'Recharged',
    'Balanced',
    'Sleepy',
    'Exhausted',
  ];
  final _sleepEmojis = const ['⚡', '🙂', '😴', '🥱'];
  Timer? _autosaveTimer;
  bool _didInitFromProfile = false;
  bool _autosaveInFlight = false;
  String? _lastSavedFingerprint;

  DateTime? _birthDate;
  String _gender = _notSpecified;
  String _relationship = _notSpecified;
  String _occupation = _notSpecified;
  double _stressLevel = 1;
  double _sleepLevel = 2;

  String _pickOption(String? raw, List<String> options, {String? fallback}) {
    final v = raw?.trim();
    if (v != null && options.contains(v)) {
      return v;
    }
    return fallback ?? options.first;
  }

  double _pickSlider(String? raw, List<String> options, double fallback) {
    final index = options.indexOf(raw?.trim() ?? '');
    return index >= 0 ? index.toDouble() : fallback;
  }

  String get _stressLabel => _stressOptions[_stressLevel.round()];
  String get _stressEmoji => _stressEmojis[_stressLevel.round()];
  String get _sleepLabel => _sleepOptions[_sleepLevel.round()];
  String get _sleepEmoji => _sleepEmojis[_sleepLevel.round()];
  String? get _zodiacSign =>
      _birthDate == null ? null : zodiacFromDate(_birthDate!);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromProfile) return;
    final p = context.read<AppState>().profile;
    _birthDate = parseBirthDate(p.birthDate);
    _gender = _pickOption(p.gender, _genders, fallback: _notSpecified);
    _relationship =
        _pickOption(p.relationship, _relationships, fallback: _notSpecified);
    _occupation =
        _pickOption(p.occupation, _occupations, fallback: _notSpecified);
    _stressLevel = _pickSlider(p.stressLevel, _stressOptions, 1);
    _sleepLevel = _pickSlider(p.sleepLevel, _sleepOptions, 2);
    _lastSavedFingerprint = _profileFingerprint(_buildProfile());
    _didInitFromProfile = true;
  }

  String? _nullable(String value) => value == _notSpecified ? null : value;

  UserProfile _buildProfile() {
    return UserProfile(
      birthDate: _birthDate == null ? null : formatBirthDate(_birthDate!),
      gender: _nullable(_gender),
      relationship: _nullable(_relationship),
      occupation: _nullable(_occupation),
      stressLevel: _stressLabel,
      sleepLevel: _sleepLabel,
      zodiacSign: _zodiacSign,
    );
  }

  String _profileFingerprint(UserProfile profile) => profile.toMap().toString();

  Future<void> _save({bool showFeedback = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final profile = _buildProfile();
    final fingerprint = _profileFingerprint(profile);
    if (!showFeedback && fingerprint == _lastSavedFingerprint) {
      return;
    }

    try {
      _autosaveInFlight = true;
      await context.read<AppState>().saveProfile(profile);
      _lastSavedFingerprint = fingerprint;
      if (!mounted) return;
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile update failed: $e')),
      );
    } finally {
      _autosaveInFlight = false;
    }
  }

  void _scheduleAutosave() {
    if (!_didInitFromProfile || _autosaveInFlight) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 450), () {
      _save();
    });
  }

  void _updateForm(VoidCallback change) {
    setState(change);
    _scheduleAutosave();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
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
                    _dateField(
                      label: 'Birthday',
                      value: _birthDate,
                      onTap: _pickBirthDate,
                    ),
                    _infoBadge(
                      label: 'Zodiac sign',
                      value: _zodiacSign ?? 'Will appear after birthday',
                    ),
                    _dropdownField(
                      label: 'Gender',
                      value: _gender,
                      options: _genders,
                      onChanged: (v) =>
                          _updateForm(() => _gender = v ?? _notSpecified),
                    ),
                    _dropdownField(
                      label: 'Relationship status',
                      value: _relationship,
                      options: _relationships,
                      onChanged: (v) =>
                          _updateForm(() => _relationship = v ?? _notSpecified),
                    ),
                    _dropdownField(
                      label: 'Occupation',
                      value: _occupation,
                      options: _occupations,
                      onChanged: (v) =>
                          _updateForm(() => _occupation = v ?? _notSpecified),
                    ),
                    _moodSlider(
                      label: 'Stress level',
                      value: _stressLevel,
                      emoji: _stressEmoji,
                      currentLabel: _stressLabel,
                      onChanged: (v) => _updateForm(() => _stressLevel = v),
                    ),
                    _moodSlider(
                      label: 'Sleep pattern',
                      value: _sleepLevel,
                      emoji: _sleepEmoji,
                      currentLabel: _sleepLabel,
                      onChanged: (v) => _updateForm(() => _sleepLevel = v),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Builder(
        builder: (fieldContext) => InkWell(
          onTap: () async {
            final selected = await _showDropdownMenu(
              context: fieldContext,
              value: value,
              options: options,
            );
            if (selected == null) return;
            onChanged(selected);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '',
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ).copyWith(labelText: label),
            isEmpty: value == null || value.isEmpty,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showDropdownMenu({
    required BuildContext context,
    required String? value,
    required List<String> options,
  }) async {
    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay).dx,
        renderBox.localToGlobal(Offset.zero, ancestor: overlay).dy +
            renderBox.size.height,
        260,
        0,
      ),
      Offset.zero & overlay.size,
    );

    return showMenu<String>(
      context: context,
      position: position,
      initialValue: value,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      items: options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              height: 48,
              child: SizedBox(
                width: 220,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final text =
        value == null ? 'Select your birthday' : formatBirthDateDisplay(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: '',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ).copyWith(labelText: label),
          child: Row(
            children: [
              Expanded(child: Text(text)),
              const Icon(Icons.cake_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBadge({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppPalette.color100.withValues(alpha: 0.18),
          border:
              Border.all(color: AppPalette.color300.withValues(alpha: 0.35)),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _moodSlider({
    required String label,
    required double value,
    required String emoji,
    required String currentLabel,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppPalette.color300.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Text(currentLabel),
              ],
            ),
            Slider(
              value: value,
              min: 0,
              max: 3,
              divisions: 3,
              label: currentLabel,
              onChanged: onChanged,
            ),
          ],
        ),
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

  Future<void> _pickBirthDate() async {
    final picked = await showBirthDatePickerDialog(
      context: context,
      initialDate: _birthDate,
    );
    if (picked == null) return;
    _updateForm(() => _birthDate = picked);
  }
}
