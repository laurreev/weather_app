import 'package:flutter/material.dart';
import 'package:weather_buddy/services/weather_service.dart';
import 'package:weather_buddy/services/database_helper.dart';
import 'package:weather_buddy/utils/temperature_utils.dart';
import 'package:weather_buddy/utils/wind_speed_utils.dart';
import 'package:weather_buddy/widgets/cloud_pattern.dart';
import 'package:intl/intl.dart';
import 'package:weather_buddy/models/weather.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService = WeatherService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Weather> _savedWeathers = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _temperatureUnit = '°C';
  String _windSpeedUnit = 'm/s';
  int _updateFrequency = 3600000;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadSettings();
      await _loadWeathers();
      if (_savedWeathers.isEmpty) {
        await _addCurrentLocationWeather();
      }
      _startAutoUpdate();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing app: $e';
        _isLoading = false;
      });
    }
  }

  void _startAutoUpdate() {
    Future.delayed(Duration(milliseconds: _updateFrequency), () async {
      if (mounted) {
        for (var weather in _savedWeathers) {
          await _refreshWeather(weather);
        }
        _startAutoUpdate(); // Schedule next update
      }
    });
  }

  Future<void> _loadSettings() async {
    try {
      final unit = await _databaseHelper.getTemperatureUnit();
      final windUnit = await _databaseHelper.getWindSpeedUnit();
      final frequency = await _databaseHelper.getUpdateFrequency();
      setState(() {
        _temperatureUnit = unit;
        _windSpeedUnit = windUnit;
        _updateFrequency = frequency;
      });
    } catch (e) {
      // Use defaults if there's an error
      setState(() {
        _temperatureUnit = '°C';
        _windSpeedUnit = 'm/s';
        _updateFrequency = 3600000;
      });
    }
  }

  Future<void> _addCurrentLocationWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _errorMessage = 'Location services are disabled. Please enable them in settings.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _errorMessage = 'Location permission is required for current location weather.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _errorMessage = 'Location permissions are permanently denied. Please enable them in settings.');
        return;
      }

      setState(() => _isLoading = true);
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final weatherData = await _weatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      final weather = Weather(
        city: weatherData['name'],
        temperature: weatherData['main']['temp'].toDouble(),
        description: weatherData['weather'][0]['description'],
        humidity: weatherData['main']['humidity'],
        windSpeed: weatherData['wind']['speed'].toDouble(),
        timestamp: DateTime.now(),
      );

      await _databaseHelper.insertWeather(weather);
      await _loadWeathers();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting current location. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeathers() async {
    try {
      setState(() => _isLoading = true);
      final weathers = await _databaseHelper.getWeathers();
      setState(() {
        _savedWeathers = weathers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading weather data';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshWeather(Weather weather) async {
    try {
      final freshData = await _weatherService.getWeatherByCity(weather.city);
      final updatedWeather = Weather(
        id: weather.id,
        city: freshData['name'],
        temperature: freshData['main']['temp'].toDouble(),
        description: freshData['weather'][0]['description'],
        humidity: freshData['main']['humidity'],
        windSpeed: freshData['wind']['speed'].toDouble(),
        timestamp: DateTime.now(),
      );
      await _databaseHelper.updateWeather(updatedWeather);
      await _loadWeathers();
    } catch (e) {
      setState(() => _errorMessage = 'Error refreshing weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
      return Scaffold(      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'lib/icon/icon.png',
                width: 32,
                height: 32,
              ),
            ),
            const Text('Weather Buddy'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              if (mounted) {
                await _loadSettings();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCityDialog(context),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF4A90E2),   // Sky blue
                            const Color(0xFF87CEEB),   // Light sky blue
                            const Color(0xFFE6F3FF),   // Very light blue
                          ],
                        ),
                      ),
                    ),
                    // Cloud pattern overlay
                    const SizedBox.expand(
                      child: CloudPattern(
                        color: Colors.white,
                        opacity: 0.08,
                      ),
                    ),
                    // Weather list
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _savedWeathers.length,
                      itemBuilder: (context, index) {
                        final weather = _savedWeathers[index];
                        
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _WeatherCard(
                              weather: weather,
                              temperatureUnit: _temperatureUnit,
                              windSpeedUnit: _windSpeedUnit,
                              isCurrentLocation: true,
                              onRefresh: () => _refreshWeather(weather),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: weather,
                              ),
                            ),
                          );
                        }

                        return Dismissible(
                          key: Key(weather.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) async {
                            await _databaseHelper.deleteWeather(weather.id!);
                            setState(() {
                              _savedWeathers.removeAt(index);
                            });
                          },
                          child: _WeatherCard(
                            weather: weather,
                            temperatureUnit: _temperatureUnit,
                            windSpeedUnit: _windSpeedUnit,
                            onRefresh: () => _refreshWeather(weather),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: weather,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }  // Weather items are built directly in ListView.builder
  Future<void> _showAddCityDialog(BuildContext context) async {
    String? selectedCity;
    List<String> filteredCities = [];
    final controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add City'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Search city/municipality',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredCities = WeatherService.philippineCities
                        .where((city) => city.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: controller.text.isEmpty
                    ? const Center(
                        child: Text('Type to search for a city or municipality'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];
                          return ListTile(
                            title: Text(city),
                            onTap: () {
                              setState(() {
                                selectedCity = city;
                                controller.text = city;
                              });
                            },
                            tileColor: selectedCity == city ? Colors.blue.withOpacity(0.1) : null,
                          );
                        },
                      ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedCity == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a city from the list')),
                  );
                  return;
                }                try {
                  final weatherData = await _weatherService.getWeatherByCity(selectedCity!);
                  final weather = Weather(
                    city: weatherData['name'],
                    temperature: weatherData['main']['temp'].toDouble(),
                    description: weatherData['weather'][0]['description'],
                    humidity: weatherData['main']['humidity'],
                    windSpeed: weatherData['wind']['speed'].toDouble(),
                    timestamp: DateTime.now(),
                  );
                  await _databaseHelper.insertWeather(weather);
                  await _loadWeathers();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: Could not add city. Please try again.')),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Weather weather;
  final String temperatureUnit;
  final String windSpeedUnit;
  final VoidCallback onRefresh;
  final VoidCallback onTap;
  final bool isCurrentLocation;

  const _WeatherCard({
    required this.weather,
    required this.temperatureUnit,
    required this.windSpeedUnit,
    required this.onRefresh,
    required this.onTap,
    this.isCurrentLocation = false,
  });

  @override
  Widget build(BuildContext context) {    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isCurrentLocation ? 12 : 16,
        vertical: isCurrentLocation ? 12 : 8,
      ),
      color: isCurrentLocation ? const Color(0xFF4A90E2) : Colors.black26,
      elevation: isCurrentLocation ? 8 : 0,
      child: InkWell(
        onTap: onTap,        child: Padding(
          padding: EdgeInsets.all(isCurrentLocation ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(                    child: Text(
                      weather.city,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: isCurrentLocation ? 28 : 24,
                        fontWeight: isCurrentLocation ? FontWeight.bold : FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: onRefresh,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [                  Text(
                    TemperatureUtils.formatTemperature(
                      TemperatureUtils.convertTemperature(
                        weather.temperature,
                        '°C',
                        temperatureUnit
                      ),
                      temperatureUnit
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: isCurrentLocation ? 48 : 32,
                      fontWeight: isCurrentLocation ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [                      Text(
                        weather.description.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: isCurrentLocation ? 20 : 16,
                          fontWeight: isCurrentLocation ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Humidity: ${weather.humidity}%  •  Wind: ${WindSpeedUtils.formatWindSpeed(
                          WindSpeedUtils.convertWindSpeed(weather.windSpeed, 'm/s', windSpeedUnit),
                          windSpeedUnit
                        )}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isCurrentLocation ? Colors.white : Colors.white70,
                          fontSize: isCurrentLocation ? 18 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated: ${DateFormat('MMM d, h:mm a').format(weather.timestamp)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isCurrentLocation ? Colors.white : Colors.white70,
                          fontSize: isCurrentLocation ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
