import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_buddy/models/weather.dart';
import 'package:weather_buddy/pages/home_page.dart';
import 'package:weather_buddy/pages/weather_detail_page.dart';
import 'package:weather_buddy/pages/settings_page.dart';
import 'package:weather_buddy/theme/app_theme.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize FFI for sqflite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) {
          // Calculate the scaling factor based on the design size
          final mediaQuery = MediaQuery.of(context);
          final designSize = Size(1080, 2400);
          final scale = mediaQuery.size.width / designSize.width;
          
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaleFactor: scale,
            ),
            child: const HomePage(),
          );
        },
      ),      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/detail':
            final weather = settings.arguments as Weather;
            return MaterialPageRoute(
              builder: (context) => WeatherDetailPage(weather: weather),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (context) => const SettingsPage(),
            );
          default:
            return null;
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

