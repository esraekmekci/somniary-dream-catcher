import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class UserService {
  UserService(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<void> ensureUserDoc(String uid) async {
    final ref = userRef(uid);
    final snap = await ref.get();
    if (snap.exists) {
      return;
    }
    await ref.set({
      'createdAt': FieldValue.serverTimestamp(),
      'isPremium': false,
      'freeQuotaDate': '',
      'freeQuotaUsed': 0,
      'profile': UserProfile().toMap(),
      'aiSummary': {
        'themesSummary': '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUser(String uid) {
    return userRef(uid).snapshots();
  }

  Future<void> updateProfile(String uid, UserProfile profile) {
    return userRef(uid)
        .set({'profile': profile.toMap()}, SetOptions(merge: true));
  }
}
