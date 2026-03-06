import 'package:flutter_test/flutter_test.dart';
import 'package:somniary_dream_catcher/core/utils/date_utils.dart';

void main() {
  test('ymdDate formats correctly', () {
    final d = DateTime(2026, 2, 25, 21, 10);
    expect(ymdDate(d), '2026-02-25');
  });

  test('isSameYmd returns true only same day', () {
    expect(isSameYmd('2026-02-25', DateTime(2026, 2, 25, 1)), true);
    expect(isSameYmd('2026-02-24', DateTime(2026, 2, 25, 1)), false);
  });
}
