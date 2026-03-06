import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../state/app_state.dart';
import '../widgets/mystic_background.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _sending = false;
  bool _refreshing = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await context.read<AppState>().sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğrulama e-postası tekrar gönderildi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-posta gönderilemedi: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await context.read<AppState>().reloadCurrentUser();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final email = appState.user?.email ?? '-';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MysticBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('E-posta Doğrulama'),
          actions: [
            IconButton(
              tooltip: 'Çıkış yap',
              onPressed: appState.signOut,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hesabını doğrula',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('$email adresine doğrulama bağlantısı gönderdik.'),
                      const SizedBox(height: 8),
                      Text(
                        'E-postayı onayladıktan sonra "Doğrulamayı yenile" butonuna bas.',
                        style: TextStyle(
                          color: isDark
                              ? AppPalette.darkTextSecondary
                              : AppPalette.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: _refreshing ? null : _refresh,
                              child: _refreshing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Doğrulamayı yenile'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _sending ? null : _resend,
                              child: _sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Tekrar e-posta gönder'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
