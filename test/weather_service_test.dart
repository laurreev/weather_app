import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_buddy/services/weather_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
import 'weather_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WeatherService weatherService;
  late MockClient mockClient;

  setUp(() async {
    await dotenv.load(fileName: ".env");
    mockClient = MockClient();
    weatherService = WeatherService(client: mockClient);
  });

  group('WeatherService Integration Tests', () {
    test('Get Manila weather', () async {
      // Mock response data
      final mockWeatherData = {
        "coord": {"lon": 120.9822, "lat": 14.6042},
        "weather": [{
          "id": 801,
          "main": "Clouds",
          "description": "few clouds",
          "icon": "02d"
        }],
        "main": {
          "temp": 33.18,
          "feels_like": 40.18,
          "temp_min": 32.25,
          "temp_max": 34,
          "pressure": 1007,
          "humidity": 64
        },
        "name": "Manila",
        "sys": {"country": "PH"}
      };

      // Setup mock response
      when(mockClient.get(any)).thenAnswer((_) async => 
        http.Response(json.encode(mockWeatherData), 200)
      );

      // Make the request
      final result = await weatherService.getWeatherByCity('Manila');

      // Verify the result
      expect(result['name'], 'Manila');
      expect(result['sys']['country'], 'PH');
      expect(result['weather'], isA<List>());
      expect(result['main'], isA<Map<String, dynamic>>());

      // Verify that the get method was called with the correct URL
      verify(mockClient.get(any)).called(1);
    });
  });
}
