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
  bool _snackbarShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<WeatherViewModel>(context, listen: false);
      final lastCity = await viewModel.loadLastCity();

      if (lastCity != null && lastCity.isNotEmpty) {
        _controller.text = lastCity;
        await viewModel.getWeather(lastCity);
        _showOfflineSnackbarIfNeeded(viewModel.error);
      }
    });
  }

  void _showOfflineSnackbarIfNeeded(String? error) {
    if (error != null &&
        error.contains("predmemorije") &&
        !_snackbarShown &&
        context.mounted) {
      _snackbarShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Prikazani su podaci iz predmemorije (offline način rada).",
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<WeatherViewModel>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: "Unesi grad",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) async {
                    if (value.isNotEmpty) {
                      await viewModel.saveLastCity(value);
                      await viewModel.getWeather(value);
                      _showOfflineSnackbarIfNeeded(viewModel.error);
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (viewModel.isLoading)
                  const CircularProgressIndicator()
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: viewModel.error != null
                            ? Column(
                                key: const ValueKey('error'),
                                children: [
                                  Text(
                                    viewModel.error!,
                                    style: TextStyle(
                                      color: viewModel.error!
                                              .contains("predmemorije")
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final city = _controller.text;
                                      if (city.isNotEmpty) {
                                        await viewModel.getWeather(city);
                                        _showOfflineSnackbarIfNeeded(
                                            viewModel.error);
                                      }
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Pokušaj ponovno"),
                                  ),
                                ],
                              )
                            : viewModel.weather != null
                                ? Column(
                                    key: ValueKey(
                                        viewModel.weather!.description),
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
                                      Text(
                                          "Vlažnost: ${viewModel.weather!.humidity}%"),
                                      Text(
                                          "Vjetar: ${viewModel.weather!.windSpeed} m/s"),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Prognoza za 5 dana (15:00)",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: viewModel.dailyForecast
                                            .map((item) {
                                          return Column(
                                            children: [
                                              Text(
                                                "${item.dateTime.day}.${item.dateTime.month}.",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              Image.network(
                                                'https://openweathermap.org/img/wn/${item.iconCode}@2x.png',
                                                width: 50,
                                                height: 50,
                                              ),
                                              Text(
                                                "${item.temperature.toStringAsFixed(0)}°C",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
