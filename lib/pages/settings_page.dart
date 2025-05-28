import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _temperatureUnit = '°C';
  String _windSpeedUnit = 'm/s';
  int _updateFrequency = 3600000; // 1 hour in milliseconds
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final unit = await _dbHelper.getTemperatureUnit();
    final windUnit = await _dbHelper.getWindSpeedUnit();
    final frequency = await _dbHelper.getUpdateFrequency();
    setState(() {
      _temperatureUnit = unit;
      _windSpeedUnit = windUnit;
      _updateFrequency = frequency;
    });
  }

  String _getUpdateFrequencyLabel(int milliseconds) {
    final minutes = milliseconds ~/ 60000;
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Settings'),
      ),
      body: Container(
        decoration: BoxDecoration(          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4A90E2),   // Sky blue
              const Color(0xFF87CEEB),   // Light sky blue
              const Color(0xFFE6F3FF),   // Very light blue
            ],
          ),
        ),
        child: ListView(
          children: [
            // Temperature Unit Section
            Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text('Temperature Unit'),
                subtitle: Text(_temperatureUnit),
                trailing: DropdownButton<String>(
                  value: _temperatureUnit,
                  items: ['°C', '°F']
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      await _dbHelper.updateTemperatureUnit(value);
                      setState(() => _temperatureUnit = value);
                    }
                  },
                ),
              ),
            ),

            // Wind Speed Unit Section
            Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text('Wind Speed Unit'),
                subtitle: Text(_windSpeedUnit),
                trailing: DropdownButton<String>(
                  value: _windSpeedUnit,
                  items: ['m/s', 'km/h', 'mph']
                      .map((unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      await _dbHelper.updateWindSpeedUnit(value);
                      setState(() => _windSpeedUnit = value);
                    }
                  },
                ),
              ),
            ),

            // Update Frequency Section
            Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: const Text('Update Frequency'),
                subtitle: Text(_getUpdateFrequencyLabel(_updateFrequency)),
                trailing: DropdownButton<int>(
                  value: _updateFrequency,
                  items: [
                    DropdownMenuItem(
                      value: 900000, // 15 minutes
                      child: const Text('15 minutes'),
                    ),
                    DropdownMenuItem(
                      value: 1800000, // 30 minutes
                      child: const Text('30 minutes'),
                    ),
                    DropdownMenuItem(
                      value: 3600000, // 1 hour
                      child: const Text('1 hour'),
                    ),
                    DropdownMenuItem(
                      value: 7200000, // 2 hours
                      child: const Text('2 hours'),
                    ),
                    DropdownMenuItem(
                      value: 21600000, // 6 hours
                      child: const Text('6 hours'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      await _dbHelper.updateUpdateFrequency(value);
                      setState(() => _updateFrequency = value);
                    }
                  },
                ),
              ),
            ),

            // About Section
            Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: const Text('About'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        Text(
                          'Weather Buddy',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('Version 0.1.0'),
                        const SizedBox(height: 8),
                        const Text(
                          'Your friendly weather companion for the Philippines, providing detailed weather information for cities and municipalities across the country.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
