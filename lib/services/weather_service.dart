import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final String _apiKey = "fba67551ec2b9f4670f76db71b581796";
  Future<Weather> fetchWeather(String city) async {
    final url = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric&lang=hr',
    );

    final response = await http.get(url);
    if(response.statusCode==200) {
      return Weather.fromJson(json.decode(response.body));
    }
    else {
      throw Exception("Nema dostupnih podataka za $city");
    }
  }


Future<List<ForecastItem>> fetchForecast(String city) async {
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$_apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> list = data['list'];
    return list.map((item) => ForecastItem.fromJson(item)).toList();
  } else {
    throw Exception('Neuspješan dohvat prognoze');
  }
}


}