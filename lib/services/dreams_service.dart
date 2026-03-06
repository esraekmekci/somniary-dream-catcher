import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dream_entry.dart';

class DreamsService {
  DreamsService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<DreamEntry>> watchDreams(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('dreams')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DreamEntry.fromDoc).toList());
  }

  Stream<DreamEntry?> watchDream(String uid, String dreamId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('dreams')
        .doc(dreamId)
        .snapshots()
        .map((doc) => doc.exists ? DreamEntry.fromDoc(doc) : null);
  }
}
