import 'package:firebase_auth/firebase_auth.dart';

String mapAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'E-posta formatı geçersiz.';
      case 'email-already-in-use':
        return 'Bu e-posta ile zaten bir hesap var.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter gir.';
      case 'user-not-found':
        return 'Bu e-posta ile bir hesap bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Biraz sonra tekrar dene.';
      default:
        return error.message ?? 'Kimlik doğrulama hatası.';
    }
  }
  return error.toString();
}
