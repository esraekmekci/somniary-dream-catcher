import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class FunctionsService {
  FunctionsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _region = 'us-central1';

  Uri _uri(String functionName) {
    final projectId = Firebase.app().options.projectId;
    return Uri.parse(
      'https://$_region-$projectId.cloudfunctions.net/$functionName',
    );
  }

  Future<Map<String, dynamic>> interpretDream({
    required String uid,
    required String dreamText,
    required String source,
    String? chatId,
  }) async {
    final res = await _client.post(
      _uri('interpretDream'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'dreamText': dreamText,
        'source': source,
        'chatId': chatId,
      }),
    );

    if (res.statusCode >= 400) {
      throw Exception(_extractError(res.body));
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<String> transcribeAudio({
    required String uid,
    String? storagePath,
    String? audioBase64,
  }) async {
    final res = await _client.post(
      _uri('transcribeAudio'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'storagePath': storagePath,
        'audioBase64': audioBase64,
      }),
    );
    if (res.statusCode >= 400) {
      throw Exception(_extractError(res.body));
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['text'] as String? ?? '';
  }

  String _extractError(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map['error'] as String? ?? raw;
    } catch (_) {
      return raw;
    }
  }
}
