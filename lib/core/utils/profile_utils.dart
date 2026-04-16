import 'package:flutter/services.dart';

String formatBirthDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String formatBirthDateDisplay(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatBirthDateInput(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length && i < 8; i++) {
    if (i == 2 || i == 4) {
      buffer.write('/');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

DateTime birthDateMin() => DateTime(1900, 1, 1);

DateTime birthDateMax() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

bool isBirthDateInAllowedRange(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final min = birthDateMin();
  final max = birthDateMax();
  return !normalized.isBefore(min) && !normalized.isAfter(max);
}

DateTime? parseBirthDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }

  final normalized = raw.trim();
  if (normalized.contains('-')) {
    final parts = normalized.split('-');
    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }

    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  final parts = normalized.split('/');
  if (parts.length != 3) {
    return null;
  }

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return null;
  }

  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  if (!isBirthDateInAllowedRange(date)) {
    return null;
  }
  return date;
}

String zodiacFromDate(DateTime date) {
  final month = date.month;
  final day = date.day;

  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
    return 'Scorpio';
  }
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
    return 'Sagittarius';
  }
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
    return 'Capricorn';
  }
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
    return 'Aquarius';
  }
  return 'Pisces';
}

class BirthDateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatBirthDateInput(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
