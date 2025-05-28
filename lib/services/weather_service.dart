import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final List<String> baseUrls = [
    'https://api.openweathermap.org/data/2.5/weather',
    'http://api.openweathermap.org/data/2.5/weather',
  ];
  late final String apiKey;
  final http.Client client;
  final Duration timeout = const Duration(seconds: 5);

  // Comprehensive list of Philippine cities and municipalities by region
  static const Map<String, List<String>> philippineCitiesByRegion = {
    'Metro Manila': [
      'Manila', 'Quezon City', 'Makati', 'Taguig', 'Pasig', 'Parañaque',
      'Mandaluyong', 'San Juan', 'Marikina', 'Pasay', 'Caloocan', 'Las Piñas',
      'Malabon', 'Muntinlupa', 'Navotas', 'Valenzuela', 'Pateros'
    ],
    'Northern Luzon': [
      // Ilocos Region Cities
      'Baguio', 'Laoag', 'Vigan', 'San Fernando', 'Candon', 'Batac',
      'Alaminos', 'Dagupan', 'San Carlos', 'Urdaneta',
      // Ilocos Norte Municipalities
      'Bacarra', 'Badoc', 'Bangui', 'Carasi', 'Dumalneg', 'Dingras', 'Nueva Era',
      'Pagudpud', 'Paoay', 'Pasuquin', 'Piddig', 'Pinili', 'San Nicolas', 'Sarrat',
      'Solsona', 'Vintar',
      // Ilocos Sur Municipalities
      'Bantay', 'Burgos', 'Cabugao', 'Caoayan', 'Cervantes', 'Galimuyod', 'Gregorio del Pilar',
      'Lidlidda', 'Magsingal', 'Nagbukel', 'Narvacan', 'Quirino', 'Salcedo', 'San Emilio',
      'San Ildefonso', 'San Juan', 'Santa', 'Santa Catalina', 'Santa Cruz', 'Santa Lucia',
      'Santa Maria', 'Santiago', 'Santo Domingo', 'Sigay', 'Sinait', 'Sugpon', 'Suyo', 'Tagudin',
      // La Union Municipalities
      'Agoo', 'Aringay', 'Bacnotan', 'Bagulin', 'Balaoan', 'Bangar', 'Bauang', 'Burgos',
      'Caba', 'Luna', 'Naguilian', 'Pugo', 'Rosario', 'San Gabriel', 'San Juan', 'Santo Tomas',
      'Santol', 'Sudipen', 'Tubao',
      // Pangasinan Municipalities
      'Agno', 'Aguilar', 'Alcala', 'Anda', 'Asingan', 'Balungao', 'Bani', 'Basista',
      'Bautista', 'Bayambang', 'Binalonan', 'Binmaley', 'Bolinao', 'Bugallon', 'Burgos',
      'Calasiao', 'Dasol', 'Infanta', 'Labrador', 'Laoac', 'Lingayen', 'Mabini', 'Malasiqui',
      'Manaoag', 'Mangaldan', 'Mangatarem', 'Mapandan', 'Natividad', 'Pozzorubio', 'Rosales',
      'San Fabian', 'San Jacinto', 'San Manuel', 'San Nicolas', 'San Quintin', 'Santa Barbara',
      'Santa Maria', 'Santo Tomas', 'Sison', 'Sual', 'Tayug', 'Umingan', 'Urbiztondo', 'Villasis',
      // Mountain Province & CAR Municipalities
      'Bontoc', 'Sabangan', 'Sadanga', 'Sagada', 'Barlig', 'Bauko', 'Besao', 'Natonin',
      'Paracelis', 'Tadian', 'La Trinidad', 'Mankayan', 'Tuba', 'Tublay', 'Buguias', 'Bokod',
      'Kabayan', 'Kapangan', 'Kiangan', 'Lagawe', 'Lamut', 'Mayoyao', 'Asipulo', 'Aguinaldo',
      // Cagayan Valley Cities & Municipalities
      'Tuguegarao', 'Santiago', 'Ilagan', 'Cauayan',
      'Alcala', 'Amulung', 'Aparri', 'Baggao', 'Ballesteros', 'Buguey', 'Calayan',
      'Camalaniugan', 'Claveria', 'Enrile', 'Gattaran', 'Gonzaga', 'Iguig', 'Lal-lo',
      'Lasam', 'Pamplona', 'Peñablanca', 'Piat', 'Rizal', 'Sanchez-Mira', 'Santa Ana',
      'Santa Praxedes', 'Santa Teresita', 'Santo Niño', 'Solana', 'Tuao',
      // Isabela Municipalities
      'Alicia', 'Angadanan', 'Aurora', 'Benito Soliven', 'Burgos', 'Cabagan', 'Cabatuan',
      'Cordon', 'Delfin Albano', 'Dinapigue', 'Divilacan', 'Echague', 'Gamu', 'Jones',
      'Luna', 'Maconacon', 'Mallig', 'Naguilian', 'Palanan', 'Quezon', 'Quirino',
      'Ramon', 'Reina Mercedes', 'Roxas', 'San Agustin', 'San Guillermo', 'San Isidro',
      'San Manuel', 'San Mariano', 'San Mateo', 'San Pablo', 'Santa Maria', 'Santo Tomas',
      'Tumauini'
    ],
    'Central Luzon': [
      // Cities
      'Angeles', 'San Fernando', 'Malolos', 'Tarlac', 'Cabanatuan', 'Balanga',
      'Olongapo', 'Gapan', 'Munoz', 'Palayan', 'San Jose del Monte',
      // Municipalities
      'Guiguinto', 'Marilao', 'Meycauayan', 'Plaridel', 'Pulilan', 
      'Mexico', 'Mabalacat', 'Lubao', 'Porac', 'Floridablanca',
      'Gerona', 'Paniqui', 'Camiling', 'Capas', 'Concepcion',
      'Talavera', 'Guimba', 'San Jose', 'Aliaga', 'Zaragoza',      
      // Bataan Municipalities
      'Abucay', 'Bagac', 'Dinalupihan', 'Hermosa', 'Limay', 'Mariveles', 
      'Morong', 'Orani', 'Orion', 'Pilar', 'Samal',
      // Nueva Ecija Municipalities
      'Aliaga', 'Bongabon', 'Cabiao', 'Carranglan', 'Cuyapo', 'Gabaldon', 'General Mamerto Natividad',
      'General Tinio', 'Guimba', 'Jaen', 'Laur', 'Licab', 'Llanera', 'Lupao', 'Nampicuan',
      'Pantabangan', 'Peñaranda', 'Quezon', 'Rizal', 'San Antonio', 'San Isidro', 'San Leonardo',
      'Santa Rosa', 'Santo Domingo', 'Talugtug', 'Zaragoza',
      // Pampanga Municipalities
      'Apalit', 'Arayat', 'Bacolor', 'Candaba', 'Floridablanca', 'Guagua', 'Lubao',
      'Macabebe', 'Magalang', 'Masantol', 'Mexico', 'Minalin', 'Porac', 'San Luis',
      'San Simon', 'Santa Ana', 'Santa Rita', 'Santo Tomas', 'Sasmuan',
      // Bulacan Municipalities
      'Angat', 'Balagtas', 'Baliuag', 'Bocaue', 'Bulacan', 'Bustos', 'Calumpit',
      'Dona Remedios Trinidad', 'Guiguinto', 'Hagonoy', 'Marilao', 'Norzagaray', 'Obando',
      'Pandi', 'Paombong', 'Plaridel', 'Pulilan', 'San Ildefonso', 'San Miguel', 'San Rafael',
      'Santa Maria',
      // Zambales Municipalities
      'Botolan', 'Cabangan', 'Candelaria', 'Castillejos', 'Iba', 'Masinloc', 'Palauig',
      'San Antonio', 'San Felipe', 'San Marcelino', 'San Narciso', 'Santa Cruz', 'Subic'
    ],
    'Southern Luzon': [
      // CALABARZON Cities
      'Batangas City', 'Lipa', 'Lucena', 'Calamba', 'Santa Rosa', 'Tagaytay',
      'Dasmariñas', 'Antipolo', 'Imus', 'Bacoor', 'Biñan', 'San Pablo',
      // CALABARZON Municipalities
      'Tanauan', 'Nasugbu', 'Balayan', 'Lemery', 'Taal',
      'Sariaya', 'Candelaria', 'Tayabas', 'Pagbilao', 'Infanta',
      'Los Baños', 'Cabuyao', 'San Pedro', 'Silang', 'Carmona',
      // Bicol Region Cities
      'Legazpi', 'Naga', 'Sorsogon', 'Tabaco', 'Ligao', 'Masbate City',
      // Bicol Region Municipalities
      'Daraga', 'Camalig', 'Guinobatan', 'Sto. Domingo', 'Tiwi',
      'Pili', 'Calabanga', 'Goa', 'Tigaon', 'Buhi',
      'Castilla', 'Gubat', 'Irosin', 'Bulan', 'Matnog',
      // Cavite Municipalities
      'Amadeo', 'Carmona', 'General Mariano Alvarez', 'General Trias', 'Indang', 'Kawit',
      'Magallanes', 'Maragondon', 'Mendez', 'Naic', 'Noveleta', 'Rosario', 'Silang',
      'Tanza', 'Ternate',
      // Laguna Municipalities
      'Alaminos', 'Bay', 'Calauan', 'Cavinti', 'Famy', 'Kalayaan', 'Liliw', 'Luisiana',
      'Lumban', 'Mabitac', 'Magdalena', 'Majayjay', 'Nagcarlan', 'Paete', 'Pagsanjan',
      'Pakil', 'Pangil', 'Pila', 'Rizal', 'Santa Cruz', 'Santa Maria', 'Siniloan', 'Victoria',
      // Batangas Municipalities
      'Agoncillo', 'Alitagtag', 'Balete', 'Bauan', 'Calaca', 'Calatagan', 'Cuenca',
      'Ibaan', 'Laurel', 'Lobo', 'Mabini', 'Malvar', 'Mataas na Kahoy', 'Padre Garcia',
      'Rosario', 'San Jose', 'San Juan', 'San Luis', 'San Nicolas', 'San Pascual',
      'Santa Teresita', 'Taal', 'Talisay', 'Taysan', 'Tingloy', 'Tuy',
      // Quezon Municipalities
      'Agdangan', 'Alabat', 'Atimonan', 'Buenavista', 'Burdeos', 'Calauag', 'Catanauan',
      'Dolores', 'General Luna', 'General Nakar', 'Guinayangan', 'Gumaca', 'Infanta',
      'Jomalig', 'Lopez', 'Macalelon', 'Mauban', 'Mulanay', 'Padre Burgos', 'Panukulan',
      'Patnanungan', 'Perez', 'Pitogo', 'Plaridel', 'Polillo', 'Quezon', 'Real',
      'Sampaloc', 'San Andres', 'San Antonio', 'San Francisco', 'San Narciso',
      'Tagkawayan', 'Tiaong', 'Unisan'
    ],
    'Visayas': [
      // Western Visayas Cities
      'Iloilo City', 'Bacolod', 'Roxas', 'Kalibo', 'San Carlos', 'Silay',
      'Kabankalan', 'Bago', 'Passi', 'Victorias',
      // Western Visayas Municipalities
      'Oton', 'Pavia', 'Santa Barbara', 'Miagao', 'Dumangas',
      'Talisay', 'Murcia', 'Pontevedra', 'Hinigaran', 'Cadiz',
      // Central Visayas Cities
      'Cebu City', 'Lapu-Lapu', 'Mandaue', 'Tagbilaran', 'Dumaguete',
      'Talisay', 'Danao', 'Toledo', 'Bogo', 'Carcar',
      // Central Visayas Municipalities
      'Cordova', 'Minglanilla', 'Consolacion', 'Carmen', 'Liloan',
      'Panglao', 'Dauis', 'Jagna', 'Tubigon', 'Ubay',
      // Eastern Visayas Cities
      'Tacloban', 'Ormoc', 'Catbalogan', 'Maasin', 'Borongan', 'Baybay',
      // Eastern Visayas Municipalities
      'Palo', 'Tanauan', 'Tolosa', 'Dulag', 'Abuyog',
      'Catarman', 'Laoang', 'Allen', 'Calbayog', 'Guiuan'
    ],
    'Mindanao': [
      // Northern Mindanao
      'Cagayan de Oro', 'Iligan', 'Malaybalay', 'Valencia', 'Oroquieta', 'Ozamiz',
      'Gingoog', 'El Salvador', 'Tangub',
      // Northern Mindanao Municipalities
      'Opol', 'Tagoloan', 'Villanueva', 'Jasaan', 'Balingasag',
      // Southern Mindanao Cities
      'Davao City', 'Digos', 'Tagum', 'Panabo', 'Mati', 'Samal',
      // Southern Mindanao Municipalities
      'Sta. Cruz', 'Hagonoy', 'Malita', 'Kapalong', 'Carmen',
      // SOCCSKSARGEN Cities
      'General Santos', 'Koronadal', 'Kidapawan', 'Tacurong',
      // SOCCSKSARGEN Municipalities
      'Polomolok', 'Tupi', 'Surallah', 'Lake Sebu', 'Kabacan',
      // Zamboanga Peninsula Cities
      'Zamboanga City', 'Dipolog', 'Pagadian', 'Isabela City', 'Dapitan',
      // Zamboanga Peninsula Municipalities
      'Ipil', 'Siay', 'Molave', 'Sindangan', 'Siocon',
      // Caraga Cities
      'Butuan', 'Surigao', 'Tandag', 'Bislig', 'Bayugan', 'Cabadbaran',
      // Caraga Municipalities
      'Buenavista', 'Nasipit', 'Prosperidad', 'San Francisco', 'Placer'
    ]
  };

  // Flattened list of all cities for easy access
  static final List<String> philippineCities = philippineCitiesByRegion.values
      .expand((cities) => cities)
      .toList();

  WeatherService({http.Client? client}) : client = client ?? http.Client() {
    apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API key not found in environment variables');
    }
  }

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    Exception? lastException;
    
    for (String baseUrl in baseUrls) {
      try {
        final url = Uri.parse('$baseUrl?q=$city,PH&appid=$apiKey&units=metric');
        _logNetworkRequest('Fetching weather data for $city from $baseUrl');
        
        final response = await client.get(url).timeout(timeout);

        if (response.statusCode == 200) {
          _logNetworkSuccess('Successfully fetched weather data for $city');
          return json.decode(response.body);
        } else {
          _logNetworkError('HTTP ${response.statusCode} error for $city', 
              Exception('Failed with status ${response.statusCode}'));
        }
      } on TimeoutException {
        final error = Exception('Request timed out after ${timeout.inSeconds} seconds');
        _logNetworkError('Timeout for $city', error);
        lastException = error;
        continue;
      } on SocketException catch (e) {
        final error = Exception('Network error: ${e.message}');
        _logNetworkError('Network error for $city', error);
        lastException = error;
        continue;
      } catch (e) {
        final error = Exception('Error fetching weather data: $e');
        _logNetworkError('Unknown error for $city', error);
        lastException = error;
        continue;
      }
    }

    throw lastException ?? Exception('Failed to fetch weather data after trying all URLs');
  }

  Future<Map<String, dynamic>> getWeatherByLocation(double lat, double lon) async {
    Exception? lastException;
    
    for (String baseUrl in baseUrls) {
      try {
        final url = Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
        _logNetworkRequest('Fetching weather data for location ($lat, $lon) from $baseUrl');
        
        final response = await client.get(url).timeout(timeout);

        if (response.statusCode == 200) {
          _logNetworkSuccess('Successfully fetched weather data for location ($lat, $lon)');
          return json.decode(response.body);
        } else {
          _logNetworkError('HTTP ${response.statusCode} error for location ($lat, $lon)', 
              Exception('Failed with status ${response.statusCode}'));
        }
      } on TimeoutException {
        final error = Exception('Request timed out after ${timeout.inSeconds} seconds');
        _logNetworkError('Timeout for location ($lat, $lon)', error);
        lastException = error;
        continue;
      } on SocketException catch (e) {
        final error = Exception('Network error: ${e.message}');
        _logNetworkError('Network error for location ($lat, $lon)', error);
        lastException = error;
        continue;
      } catch (e) {
        final error = Exception('Error fetching weather data: $e');
        _logNetworkError('Unknown error for location ($lat, $lon)', error);
        lastException = error;
        continue;
      }
    }

    throw lastException ?? Exception('Failed to fetch weather data after trying all URLs');
  }

  // Network logging methods
  void _logNetworkRequest(String message) {
    print('📡 REQUEST: $message');
  }

  void _logNetworkSuccess(String message) {
    print('✅ SUCCESS: $message');
  }

  void _logNetworkError(String message, Exception error) {
    print('❌ ERROR: $message');
    print('   Details: ${error.toString()}');
  }

  // Get weather for all cities in a specific region
  Future<List<Map<String, dynamic>>> getWeatherByRegion(String region) async {
    if (!philippineCitiesByRegion.containsKey(region)) {
      throw Exception('Invalid region name');
    }

    List<Map<String, dynamic>> results = [];
    for (String city in philippineCitiesByRegion[region]!) {
      try {
        final weather = await getWeatherByCity(city);
        results.add(weather);
      } catch (e) {
        _logNetworkError('Error fetching weather for $city', 
            e is Exception ? e : Exception(e.toString()));
      }
    }
    return results;
  }

  // Get list of all regions
  List<String> getAllRegions() {
    return philippineCitiesByRegion.keys.toList();
  }

  // Get list of cities in a specific region
  List<String> getCitiesByRegion(String region) {
    return philippineCitiesByRegion[region] ?? [];
  }

  void dispose() {
    client.close();
  }
}
