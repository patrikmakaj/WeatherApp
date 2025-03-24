import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    } catch (e) {
      _error = '$e';
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
}
