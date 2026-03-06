import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../core/utils/auth_error_mapper.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../widgets/mystic_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _notSpecified = 'Not specified';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _ageRanges = const ['18-24', '25-34', '35-44', '45+'];
  final _occupations = const [
    _notSpecified,
    'Student',
    'Working',
    'Self-employed',
    'Freelancer',
    'Other',
  ];
  final _stress = const [_notSpecified, 'Low', 'Moderate', 'High'];
  final _relationships = const [
    _notSpecified,
    'Single',
    'In relationship',
    'Married',
    'Complicated',
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

  String _ageRange = '25-34';
  String _occupation = _notSpecified;
  String _stressLevel = 'Moderate';
  String _relationship = _notSpecified;
  String _zodiacSign = _notSpecified;

  bool _isSignUp = false;
  bool _loading = false;

  String? _nullable(String value) => value == _notSpecified ? null : value;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final appState = context.read<AppState>();

    try {
      if (_isSignUp) {
        final profile = UserProfile(
          ageRange: _ageRange,
          occupation: _nullable(_occupation),
          stressLevel: _nullable(_stressLevel),
          relationship: _nullable(_relationship),
          zodiacSign: _nullable(_zodiacSign),
        );

        await appState.signUpWithProfile(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          profile: profile,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı. Doğrulama e-postası gönderildi.'),
          ),
        );
      } else {
        await appState.signIn(
            _emailController.text.trim(), _passwordController.text);
        if (!mounted) return;
        if (!appState.isEmailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('E-posta henüz doğrulanmamış. Gelen kutunu kontrol et.'),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapAuthError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MysticBackground(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppPalette.color700
                                      : AppPalette.color100)
                                  .withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.nights_stay_rounded,
                              size: 42,
                              color: isDark
                                  ? AppPalette.color100
                                  : AppPalette.color700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text('Somniary',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          Text(
                            'Where your dreams\nfind a home.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 44,
                                  height: 1.08,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"Between the waking world and the starlit sky, your soul speaks in symbols. Let us listen together."',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              color: isDark
                                  ? AppPalette.darkTextSecondary
                                  : AppPalette.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: (isDark
                                        ? AppPalette.color800
                                        : AppPalette.color100)
                                    .withValues(alpha: 0.45),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _modeButton(
                                      active: !_isSignUp,
                                      label: 'Login',
                                      onTap: _loading
                                          ? null
                                          : () =>
                                              setState(() => _isSignUp = false),
                                    ),
                                  ),
                                  Expanded(
                                    child: _modeButton(
                                      active: _isSignUp,
                                      label: 'Register',
                                      onTap: _loading
                                          ? null
                                          : () =>
                                              setState(() => _isSignUp = true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'Email Address'),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) return 'E-posta zorunlu.';
                                if (!v.contains('@')) {
                                  return 'Geçerli e-posta gir.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              validator: (value) {
                                if ((value ?? '').length < 6) {
                                  return 'Şifre en az 6 karakter olmalı.';
                                }
                                return null;
                              },
                            ),
                            if (_isSignUp) ...[
                              const SizedBox(height: 16),
                              Divider(
                                color: isDark
                                    ? AppPalette.color700
                                        .withValues(alpha: 0.45)
                                    : AppPalette.color200,
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'PERSONAL ALCHEMY (OPTIONAL)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: isDark
                                        ? AppPalette.color200
                                        : AppPalette.color700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _dropdownField(
                                label: 'Age',
                                value: _ageRange,
                                options: _ageRanges,
                                onChanged: (v) =>
                                    setState(() => _ageRange = v ?? _ageRange),
                              ),
                              _dropdownField(
                                label: 'Zodiac',
                                value: _zodiacSign,
                                options: _zodiacSigns,
                                onChanged: (v) => setState(
                                    () => _zodiacSign = v ?? _notSpecified),
                              ),
                              _dropdownField(
                                label: 'Occupation',
                                value: _occupation,
                                options: _occupations,
                                onChanged: (v) => setState(
                                    () => _occupation = v ?? _notSpecified),
                              ),
                              _dropdownField(
                                label: 'Stress level',
                                value: _stressLevel,
                                options: _stress,
                                onChanged: (v) => setState(
                                    () => _stressLevel = v ?? _notSpecified),
                              ),
                              _dropdownField(
                                label: 'Relationship status',
                                value: _relationship,
                                options: _relationships,
                                onChanged: (v) => setState(
                                    () => _relationship = v ?? _notSpecified),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text(_isSignUp
                                        ? 'Enter the Dreamscape'
                                        : 'Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeButton({
    required bool active,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active
              ? (isDark ? AppPalette.color600 : AppPalette.color300)
              : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active
                ? (isDark ? AppPalette.color50 : AppPalette.color900)
                : (isDark
                    ? AppPalette.darkTextSecondary
                    : AppPalette.lightTextSecondary),
          ),
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
      padding: const EdgeInsets.only(bottom: 10),
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
                child: Text(
                  v,
                  overflow: TextOverflow.ellipsis,
                ),
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
      ),
    );
  }
}
