import 'package:flutter_test/flutter_test.dart';
import 'package:somniary_dream_catcher/core/utils/date_utils.dart';

void main() {
  test('quota date util smoke', () {
    expect(ymdDate(DateTime(2026, 2, 25)), '2026-02-25');
  });
}
