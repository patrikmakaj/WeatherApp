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
      dateTime: DateTime.parse(json['dt_txt']),
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}
