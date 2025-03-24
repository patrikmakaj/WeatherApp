import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_view_model.dart';

class WeatherScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const WeatherScreen({super.key, required this.onToggleTheme});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<WeatherViewModel>(context, listen: false);
      final lastCity = await viewModel.loadLastCity();

      if (lastCity != null && lastCity.isNotEmpty) {
        _controller.text = lastCity;
        viewModel.getWeather(lastCity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WeatherViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vrijeme"),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Unesi grad",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  viewModel.saveLastCity(value);
                  viewModel.getWeather(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (viewModel.isLoading)
              const CircularProgressIndicator()
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: viewModel.error != null
                    ? Column(
                        key: const ValueKey('error'),
                        children: [
                          Text(
                            viewModel.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              final city = _controller.text;
                              if (city.isNotEmpty) {
                                viewModel.getWeather(city);
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Pokušaj ponovno"),
                          ),
                        ],
                      )
                    : viewModel.weather != null
                        ? Column(
                            key: ValueKey(viewModel.weather!.description),
                            children: [
                              Text(
                                "${viewModel.weather!.temperature.toStringAsFixed(1)}°C",
                                style: const TextStyle(fontSize: 40),
                              ),
                              Text(
                                viewModel.weather!.description,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Image.network(
                                'https://openweathermap.org/img/wn/${viewModel.weather!.iconCode}@2x.png',
                              ),
                              Text("Vlažnost: ${viewModel.weather!.humidity}%"),
                              Text("Vjetar: ${viewModel.weather!.windSpeed} m/s"),
                              const SizedBox(height: 20),
                              Text(
                                "Prognoza za 5 dana (15:00)",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: viewModel.dailyForecast.map((item) {
                                  return Column(
                                    children: [
                                      Text(
                                        "${item.dateTime.day}.${item.dateTime.month}.",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Image.network(
                                        'https://openweathermap.org/img/wn/${item.iconCode}@2x.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                      Text(
                                        "${item.temperature.toStringAsFixed(0)}°C",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          )
                        : const SizedBox(),
              ),
          ],
        ),
      ),
    );
  }
}
