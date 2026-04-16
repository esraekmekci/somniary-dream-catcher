import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/zodiac_sign.dart';

class ZodiacService {
  ZodiacService(this._firestore);

  final FirebaseFirestore _firestore;

  /// Fetches zodiac sign details by its English name (e.g. "Aries").
  Future<ZodiacSign?> getZodiacSign(String signName) async {
    final doc =
        await _firestore.collection('zodiac_signs').doc(signName).get();
    if (!doc.exists) return null;
    return ZodiacSign.fromMap(doc.data());
  }
}
