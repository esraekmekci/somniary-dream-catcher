import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

class ChatService {
  ChatService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesRef(
      String uid, String chatId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId)
        .collection('messages');
  }

  Stream<List<ChatMessage>> watchMessages(String uid, String chatId) {
    return _messagesRef(uid, chatId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
          final items = snap.docs.map(ChatMessage.fromDoc).toList();
          items.sort((a, b) {
            final byTime = a.createdAt.compareTo(b.createdAt);
            if (byTime != 0) return byTime;

            // If server timestamps are equal, force user -> assistant order.
            final aRole = a.role == 'user' ? 0 : 1;
            final bRole = b.role == 'user' ? 0 : 1;
            final byRole = aRole.compareTo(bRole);
            if (byRole != 0) return byRole;

            return a.id.compareTo(b.id);
          });
          return items;
        });
  }

  Future<String?> getLatestChatId(String uid) async {
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .orderBy('lastUpdatedAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  Future<String> ensureChat(String uid, {String? chatId}) async {
    if (chatId != null && chatId.isNotEmpty) {
      return chatId;
    }
    final ref =
        _firestore.collection('users').doc(uid).collection('chats').doc();
    await ref.set({
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
