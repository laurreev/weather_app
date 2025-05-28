class Weather {
  final int? id;
  final String city;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final DateTime timestamp;

  Weather({
    this.id,
    required this.city,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id as int,
      'city': city,
      'temperature': temperature,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static Weather fromMap(Map<String, dynamic> map) {
    return Weather(
      id: map['id'] != null ? map['id'] as int : null,
      city: map['city'] as String,
      temperature: map['temperature'] as double,
      description: map['description'] as String,
      humidity: map['humidity'] as int,
      windSpeed: map['windSpeed'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'Weather(id: $id, city: $city, temperature: $temperature, description: $description, humidity: $humidity, windSpeed: $windSpeed, timestamp: $timestamp)';
  }
}
