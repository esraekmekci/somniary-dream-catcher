import 'package:cloud_firestore/cloud_firestore.dart';

class DreamEntry {
  DreamEntry({
    required this.id,
    required this.createdAt,
    required this.source,
    required this.dreamText,
    this.moodTag,
    required this.interpretationText,
    required this.symbols,
    required this.themes,
    required this.autoTitle,
    required this.primaryMood,
  });

  final String id;
  final DateTime createdAt;
  final String source;
  final String dreamText;
  final String? moodTag;
  final String interpretationText;
  final List<String> symbols;
  final List<String> themes;
  final String autoTitle;
  final String primaryMood;

  factory DreamEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final interp = (data['interpretation'] as Map<String, dynamic>?) ?? {};
    return DreamEntry(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      source: data['source'] as String? ?? 'text',
      dreamText: data['dreamText'] as String? ?? '',
      moodTag: data['moodTag'] as String?,
      interpretationText: interp['text'] as String? ?? '',
      symbols: List<String>.from(interp['symbols'] ?? const []),
      themes: List<String>.from(interp['themes'] ?? const []),
      autoTitle: data['autoTitle'] as String? ?? '',
      primaryMood: data['primaryMood'] as String? ?? 'Curious',
    );
  }
}
