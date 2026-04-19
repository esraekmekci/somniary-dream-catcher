class ZodiacSign {
  ZodiacSign({
    required this.name,
    required this.symbol,
    required this.element,
    required this.dateRange,
    required this.description,
    this.dailyHoroscope,
  });

  final String name;
  final String symbol;
  final String element;
  final String dateRange;
  final String description;
  final Map<String, dynamic>? dailyHoroscope;

  /// Convenience getters for daily horoscope fields.
  String? get dailyHoroscopeText => dailyHoroscope?['text'] as String?;
  String? get dailyHoroscopeDate => dailyHoroscope?['date'] as String?;

  factory ZodiacSign.fromMap(Map<String, dynamic>? map) => ZodiacSign(
        name: map?['name'] as String? ?? '',
        symbol: map?['symbol'] as String? ?? '★',
        element: map?['element'] as String? ?? '',
        dateRange: map?['dateRange'] as String? ?? '',
        description: map?['description'] as String? ?? '',
        dailyHoroscope: map?['dailyHoroscope'] as Map<String, dynamic>?,
      );
}
