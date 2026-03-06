import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'email_verification_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Firebase yapılandırması eksik.\nflutterfire configure çalıştırıp lib/firebase_options.dart dosyasını güncelle.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (!appState.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (appState.initError != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Başlatma Hatası',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(appState.initError!),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              FilledButton(
                                onPressed: appState.reloadCurrentUser,
                                child: const Text('Tekrar dene'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: appState.signOut,
                                child: const Text('Çıkış yap'),
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
          );
        }

        if (appState.user == null) {
          return const OnboardingScreen();
        }

        if (!appState.isEmailVerified) {
          return const EmailVerificationScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
