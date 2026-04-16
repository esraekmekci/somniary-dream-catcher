class ZodiacSign {
  ZodiacSign({
    required this.name,
    required this.symbol,
    required this.element,
    required this.dateRange,
    required this.description,
  });

  final String name;
  final String symbol;
  final String element;
  final String dateRange;
  final String description;

  factory ZodiacSign.fromMap(Map<String, dynamic>? map) => ZodiacSign(
        name: map?['name'] as String? ?? '',
        symbol: map?['symbol'] as String? ?? '★',
        element: map?['element'] as String? ?? '',
        dateRange: map?['dateRange'] as String? ?? '',
        description: map?['description'] as String? ?? '',
      );
}
