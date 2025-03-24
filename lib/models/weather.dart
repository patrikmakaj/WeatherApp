class Weather {
  final String description;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String iconCode;

  Weather({
    required this.description,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['description'], 
      temperature: json['main']['temp'].toDouble(), 
      humidity: json['main']['humidity'], 
      windSpeed: json['wind']['speed'].toDouble(), 
      iconCode: json['weather'][0]['icon']
      );
  }
}