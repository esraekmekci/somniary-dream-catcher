import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.linkedDreamId,
  });

  final String id;
  final String role;
  final String text;
  final DateTime createdAt;
  final String? linkedDreamId;

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChatMessage(
      id: doc.id,
      role: data['role'] as String? ?? 'assistant',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      linkedDreamId: data['linkedDreamId'] as String?,
    );
  }
}
