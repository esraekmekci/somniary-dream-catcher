import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/bootstrap_screen.dart';
import 'services/auth_service.dart';
import 'services/functions_service.dart';
import 'services/user_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    firebaseReady = false;
  }

  runApp(SomniaryApp(firebaseReady: firebaseReady));
}

class SomniaryApp extends StatelessWidget {
  const SomniaryApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const BootstrapScreen(
          firebaseReady: false,
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(
            authService: AuthService(FirebaseAuth.instance),
            userService: UserService(FirebaseFirestore.instance),
            functionsService: FunctionsService(),
          ),
        ),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Somniary',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: appState.themeMode,
            home: const BootstrapScreen(firebaseReady: true),
          );
        },
      ),
    );
  }
}
