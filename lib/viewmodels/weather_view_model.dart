import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  Weather? _weather;
  bool _isLoading = false;
  String? _error;
  List<ForecastItem> _forecast = [];

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ForecastItem> get forecast => _forecast;

  Future<void> getWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _service.fetchWeather(city);
      _forecast = await _service.fetchForecast(city);

      // Save to local storage
      await saveWeatherToCache(city, _weather!, _forecast);
    } catch (e) {
      // Try to load from cache
      final cached = await loadWeatherFromCache(city);
      if (cached != null) {
        _weather = cached['weather'];
        _forecast = cached['forecast'];
        _error = 'Prikazani su podaci iz predmemorije (offline način rada).';
      } else {
        _error = 'Greška: $e';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ForecastItem> get dailyForecast {
    final Map<String, ForecastItem> dailyAt15h = {};

    for (var item in _forecast) {
      final isAt15h = item.dateTime.hour == 15;
      final dayKey =
          "${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}";

      if (isAt15h && !dailyAt15h.containsKey(dayKey)) {
        dailyAt15h[dayKey] = item;
      }

      if (dailyAt15h.length >= 5) break;
    }

    return dailyAt15h.values.toList();
  }

  Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', city);
  }

  Future<String?> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_city');
  }

  Future<void> saveWeatherToCache(String city, Weather weather, List<ForecastItem> forecast) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${city}_weather', jsonEncode({
      'description': weather.description,
      'temperature': weather.temperature,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'iconCode': weather.iconCode,
    }));
    prefs.setString('${city}_forecast', jsonEncode(
      forecast.map((f) => {
        'dt_txt': f.dateTime.toIso8601String(),
        'main': {'temp': f.temperature},
        'weather': [{'description': f.description, 'icon': f.iconCode}],
      }).toList(),
    ));
  }

  Future<Map<String, dynamic>?> loadWeatherFromCache(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final weatherStr = prefs.getString('${city}_weather');
    final forecastStr = prefs.getString('${city}_forecast');

    if (weatherStr != null && forecastStr != null) {
      final weather = Weather.fromJson(jsonDecode(weatherStr));
      final forecast = (jsonDecode(forecastStr) as List)
          .map((e) => ForecastItem.fromJson(e))
          .toList();
      return {'weather': weather, 'forecast': forecast};
    }

    return null;
  }
}