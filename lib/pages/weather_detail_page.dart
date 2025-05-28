import 'package:flutter/material.dart';
import 'package:weather_buddy/models/weather.dart';
import 'package:weather_buddy/services/database_helper.dart';
import 'package:weather_buddy/utils/temperature_utils.dart';
import 'package:weather_buddy/utils/wind_speed_utils.dart';
import 'package:weather_buddy/widgets/cloud_pattern.dart';
import 'package:intl/intl.dart';

class WeatherDetailPage extends StatefulWidget {
  final Weather weather;

  const WeatherDetailPage({super.key, required this.weather});

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _temperatureUnit = '°C';
  String _windSpeedUnit = 'm/s';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final tempUnit = await _dbHelper.getTemperatureUnit();
    final windUnit = await _dbHelper.getWindSpeedUnit();
    setState(() {
      _temperatureUnit = tempUnit;
      _windSpeedUnit = windUnit;
    });
  }

  String _getWeatherIcon() {
    final description = widget.weather.description.toLowerCase();
    if (description.contains('clear')) return '☀️';
    if (description.contains('cloud')) return '☁️';
    if (description.contains('rain')) return '🌧️';
    if (description.contains('snow')) return '🌨️';
    if (description.contains('thunder')) return '⛈️';
    if (description.contains('wind')) return '💨';
    if (description.contains('fog') || description.contains('mist')) return '🌫️';
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.weather.city),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A5FB4),  // Deep sky blue
                  const Color(0xFF4A90E2),  // Sky blue
                  const Color(0xFF87CEEB),  // Light sky blue
                ],
              ),
            ),
          ),
          // Animated cloud pattern overlay
          const SizedBox.expand(
            child: CloudPattern(
              color: Colors.white,
              opacity: 0.06,
            ),
          ),
          // Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Main weather information
                Card(
                  color: Colors.black26,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          _getWeatherIcon(),
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          TemperatureUtils.formatTemperature(
                            TemperatureUtils.convertTemperature(
                              widget.weather.temperature,
                              '°C',
                              _temperatureUnit,
                            ),
                            _temperatureUnit,
                          ),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          widget.weather.description.toUpperCase(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Additional weather details
                Card(
                  color: Colors.black26,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.water_drop, color: Colors.white70),
                          title: const Text('Humidity', style: TextStyle(color: Colors.white70)),
                          trailing: Text(
                            '${widget.weather.humidity}%',
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.air, color: Colors.white70),
                          title: const Text('Wind Speed', style: TextStyle(color: Colors.white70)),
                          trailing: Text(
                            WindSpeedUtils.formatWindSpeed(
                              WindSpeedUtils.convertWindSpeed(
                                widget.weather.windSpeed,
                                'm/s',
                                _windSpeedUnit,
                              ),
                              _windSpeedUnit,
                            ),
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time, color: Colors.white70),
                          title: const Text('Last Updated', style: TextStyle(color: Colors.white70)),
                          trailing: Text(
                            DateFormat('MMM d, h:mm a').format(widget.weather.timestamp),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
