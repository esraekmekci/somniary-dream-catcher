import 'package:flutter_test/flutter_test.dart';
import 'package:somniary_dream_catcher/core/utils/profile_utils.dart';
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

  test('zodiacFromDate resolves boundary dates', () {
    expect(zodiacFromDate(DateTime(2026, 3, 21)), 'Aries');
    expect(zodiacFromDate(DateTime(2026, 4, 19)), 'Aries');
    expect(zodiacFromDate(DateTime(2026, 12, 22)), 'Capricorn');
    expect(zodiacFromDate(DateTime(2026, 2, 18)), 'Aquarius');
  });

  test('birth date display and masked input use dd/mm/yyyy', () {
    final date = DateTime(2026, 4, 5);
    expect(formatBirthDateDisplay(date), '05/04/2026');
    expect(formatBirthDateInput('05042026'), '05/04/2026');
    expect(parseBirthDate('05/04/2026'), date);
  });

  test('birth date parsing rejects dates outside allowed range', () {
    expect(parseBirthDate('01/01/0050'), null);
    expect(parseBirthDate('31/12/1899'), null);
    expect(parseBirthDate('01/01/1900'), DateTime(1900, 1, 1));
  });
}
