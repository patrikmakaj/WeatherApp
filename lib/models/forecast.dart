class ForecastItem {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String iconCode;

  ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dateTime: DateTime.tryParse(json['dt_txt'] ?? json['dt']) ?? DateTime.now(),
      temperature: json['main']?['temp']?.toDouble() ?? json['temperature']?.toDouble() ?? 0.0,
      description: json['weather']?[0]?['description'] ?? json['description'] ?? '',
      iconCode: json['weather']?[0]?['icon'] ?? json['iconCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.toIso8601String(),
      'main': {'temp': temperature},
      'weather': [
        {'description': description, 'icon': iconCode}
      ]
    };
  }
}
