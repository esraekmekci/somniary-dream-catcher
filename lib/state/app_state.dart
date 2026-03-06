import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/utils/date_utils.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/functions_service.dart';
import '../services/user_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required AuthService authService,
    required UserService userService,
    required FunctionsService functionsService,
  })  : _authService = authService,
        _userService = userService,
        _functionsService = functionsService {
    _authSub = _authService.authStateChanges().listen(_onAuthChanged);
  }

  final AuthService _authService;
  final UserService _userService;
  final FunctionsService _functionsService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _userSub;

  User? user;
  bool initialized = false;
  String? initError;
  bool isPremium = false;
  int freeQuotaUsed = 0;
  String freeQuotaDate = '';
  UserProfile profile = UserProfile();
  ThemeMode themeMode = ThemeMode.system;

  bool get canUseFreeToday {
    final today = ymdDate(DateTime.now());
    if (freeQuotaDate != today) {
      return true;
    }
    return freeQuotaUsed < 1;
  }

  Future<void> _onAuthChanged(User? authUser) async {
    user = authUser;
    await _userSub?.cancel();
    if (authUser == null) {
      initialized = true;
      initError = null;
      isPremium = false;
      freeQuotaUsed = 0;
      freeQuotaDate = '';
      profile = UserProfile();
      notifyListeners();
      return;
    }

    try {
      initError = null;
      await _userService.ensureUserDoc(authUser.uid);
      _userSub = _userService.watchUser(authUser.uid).listen(
        (snap) {
          final data = snap.data() ?? {};
          isPremium = data['isPremium'] as bool? ?? false;
          freeQuotaUsed = data['freeQuotaUsed'] as int? ?? 0;
          freeQuotaDate = data['freeQuotaDate'] as String? ?? '';
          profile =
              UserProfile.fromMap(data['profile'] as Map<String, dynamic>?);
          initialized = true;
          notifyListeners();
        },
        onError: (error) {
          initialized = true;
          initError =
              'Veritabanı erişim hatası. Firestore kurallarını ve proje bağlantısını kontrol et.';
          notifyListeners();
        },
      );
    } on FirebaseException catch (e) {
      initialized = true;
      initError = 'Firestore hatası (${e.code}): ${e.message ?? ''}'.trim();
      notifyListeners();
    } catch (e) {
      initialized = true;
      initError = 'Başlatma hatası: $e';
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) {
    return _authService.signIn(email: email, password: password);
  }

  Future<void> signUp(String email, String password) {
    return _authService.signUp(email: email, password: password);
  }

  Future<void> signUpWithProfile({
    required String email,
    required String password,
    required UserProfile profile,
  }) async {
    await _authService.signUp(email: email, password: password);
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _userService.ensureUserDoc(uid);
    await _userService.updateProfile(uid, profile);
  }

  Future<void> signOut() => _authService.signOut();

  bool get isEmailVerified => user?.emailVerified ?? false;

  Future<void> sendEmailVerification() => _authService.sendEmailVerification();

  Future<void> reloadCurrentUser() async {
    await _authService.reloadCurrentUser();
    user = _authService.currentUser;
    initError = null;
    initialized = false;
    await _onAuthChanged(user);
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    final uid = user?.uid;
    if (uid == null) {
      throw Exception('User not authenticated.');
    }
    await _userService.updateProfile(uid, newProfile);
  }

  Future<Map<String, dynamic>> submitDream({
    required String text,
    required String source,
    String? chatId,
  }) async {
    final uid = user?.uid;
    if (uid == null) {
      throw Exception('User not authenticated.');
    }
    return _functionsService.interpretDream(
      uid: uid,
      dreamText: text,
      source: source,
      chatId: chatId,
    );
  }

  Future<String> transcribeFromStoragePath(String storagePath) async {
    final uid = user?.uid;
    if (uid == null) {
      throw Exception('User not authenticated.');
    }
    return _functionsService.transcribeAudio(
        uid: uid, storagePath: storagePath);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _authSub?.cancel();
    await _userSub?.cancel();
    super.dispose();
  }
}
