// lib/weather.dart (Corrected and Final Version)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

// Dedicated Gemini service class (no changes needed here)
class WeatherGeminiService {
  final GenerativeModel _model;

  WeatherGeminiService({required String apiKey})
    : _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        ],
        generationConfig: GenerationConfig(maxOutputTokens: 300),
      );

  Future<String?> generateWeatherSummary({
    required String prompt,
    required String languageCode,
  }) async {
    try {
      debugPrint("Sending this prompt to Gemini: $prompt");
      final fullPrompt =
          "You are a helpful farmer's assistant. Provide a natural, spoken-word weather summary in the $languageCode language based on the following data. Keep it concise and easy to understand. Data: $prompt";

      final response = await _model.generateContent([Content.text(fullPrompt)]);

      debugPrint("✅ Gemini response received: ${response.text}");
      return response.text;
    } catch (e) {
      debugPrint('❌ Gemini weather summary generation failed: $e');
      return null;
    }
  }
}

// Localized strings for the weather page
const Map<String, Map<String, String>> weatherStrings = {
  'hi': {
    'weather_title': 'मौसम की जानकारी',
    'current_weather': 'आज का मौसम',
    'feels_like': 'महसूस होता है',
    'humidity': 'नमी',
    'wind_speed': 'हवा की गति',
    'daily_forecast': 'अगले 7 दिनों का पूर्वानुमान',
    'high': 'अधिकतम',
    'low': 'न्यूनतम',
    'loading': 'मौसम की जानकारी लोड हो रही है...',
    'error': 'जानकारी लोड करने में विफल।',
    'retry': 'पुनः प्रयास करें',
    'location_error':
        'स्थान की जानकारी नहीं मिल सकी। कृपया लोकेशन सेवा चालू करें।',
    'speak_weather_summary': 'मौसम का सारांश सुनें',
    'ai_summary_error': 'एआई सारांश प्राप्त नहीं हो सका।',
  },
  'en': {
    'weather_title': 'Weather Information',
    'current_weather': 'Current Weather',
    'feels_like': 'Feels like',
    'humidity': 'Humidity',
    'wind_speed': 'Wind Speed',
    'daily_forecast': '7-Day Forecast',
    'high': 'High',
    'low': 'Low',
    'loading': 'Loading weather data...',
    'error': 'Failed to load data.',
    'retry': 'Retry',
    'location_error':
        'Could not get location. Please enable location services.',
    'speak_weather_summary': 'Listen to weather summary',
    'ai_summary_error': 'Could not get AI summary.',
  },
  // Add other languages here (kn, ta, te)
};

class WeatherPage extends StatefulWidget {
  final String languageCode;
  final Position? currentPosition;

  const WeatherPage({
    super.key,
    required this.languageCode,
    this.currentPosition,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Your OpenWeatherMap API key
  static const String _openWeatherApiKey =
      '555f341d870f6c33624ce9907ba0c63e'; // Your key here

  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _dailyForecast;
  String? _error;
  Position? _position;
  final Completer<void> _dataLoaderCompleter = Completer<void>();

  late FlutterTts _flutterTts;
  late WeatherGeminiService _geminiService;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    // Initialize everything in sequence
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([
        dotenv.load(fileName: '.env'),
        initializeDateFormatting(widget.languageCode),
      ]);
      await _initializeServices();
      await _initializeWeather();
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  Future<void> _initializeServices() async {
    await dotenv.load(fileName: '.env'); // Load the .env file
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      debugPrint("FATAL: GEMINI_API_KEY is not set in your .env file.");
      if (mounted) setState(() => _error = "AI Service is not configured.");
      return;
    }
    _geminiService = WeatherGeminiService(apiKey: geminiApiKey);
    _flutterTts = FlutterTts();
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _initializeWeather() async {
    if (!mounted) return;
    setState(() {
      _error = null;
      _currentWeather = null;
      _dailyForecast = null;
    });

    try {
      _position = widget.currentPosition ?? await _getCurrentLocation();
      if (_position != null) {
        await _fetchWeatherData();
        if (!_dataLoaderCompleter.isCompleted) _dataLoaderCompleter.complete();
      } else {
        throw Exception(weatherStrings[widget.languageCode]!['location_error']);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        if (!_dataLoaderCompleter.isCompleted) {
          _dataLoaderCompleter.completeError(e);
        }
      }
    }
  }

  Future<Position> _getCurrentLocation() async {
    // ... same as before ...
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  /// **ACTION**: This method is now updated to use the correct API endpoint.
  Future<void> _fetchWeatherData() async {
    if (_position == null) return;

    try {
      // Use the OpenWeatherMap free API 2.5
      final currentUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=${_position!.latitude}&lon=${_position!.longitude}&appid=$_openWeatherApiKey&units=metric&lang=${widget.languageCode}';
      final forecastUrl =
          'https://api.openweathermap.org/data/2.5/forecast?lat=${_position!.latitude}&lon=${_position!.longitude}&appid=$_openWeatherApiKey&units=metric&lang=${widget.languageCode}';

      debugPrint("Fetching current weather from: $currentUrl");
      debugPrint("Fetching forecast from: $forecastUrl");

      final currentResponse = await http.get(Uri.parse(currentUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        if (mounted) {
          setState(() {
            _currentWeather = currentData;
            _dailyForecast = _processForecastData(forecastData['list']);
          });
        }
      } else {
        // This will now correctly show the 401 error if the key is wrong
        throw Exception(
          'Failed to fetch weather (Current: ${currentResponse.statusCode}, Forecast: ${forecastResponse.statusCode})',
        );
      }
    } catch (e) {
      debugPrint("Weather fetch error: $e");
      throw Exception(weatherStrings[widget.languageCode]!['error']);
    }
  }

  List<Map<String, dynamic>> _processForecastData(List<dynamic> forecastList) {
    // Group forecasts by day
    final Map<String, List<dynamic>> dailyForecasts = {};

    for (var forecast in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!dailyForecasts.containsKey(dateKey)) {
        dailyForecasts[dateKey] = [];
      }
      dailyForecasts[dateKey]!.add(forecast);
    }

    // Process each day's forecasts into a single daily forecast
    final List<Map<String, dynamic>> processedForecasts = [];

    dailyForecasts.forEach((date, forecasts) {
      if (processedForecasts.length < 7) {
        // Only keep 7 days of forecast
        double maxTemp = -double.infinity;
        double minTemp = double.infinity;
        int mostFrequentWeatherId = 0;
        String mostFrequentIcon = '';
        String mostFrequentDescription = '';

        // Count weather conditions to find the most frequent one
        final Map<int, int> weatherCounts = {};
        for (var forecast in forecasts) {
          final temp = forecast['main']['temp'].toDouble();
          maxTemp = max(maxTemp, temp);
          minTemp = min(minTemp, temp);

          final weatherId = forecast['weather'][0]['id'];
          weatherCounts[weatherId] = (weatherCounts[weatherId] ?? 0) + 1;

          if (weatherCounts[weatherId]! >
              (weatherCounts[mostFrequentWeatherId] ?? 0)) {
            mostFrequentWeatherId = weatherId;
            mostFrequentIcon = forecast['weather'][0]['icon'];
            mostFrequentDescription = forecast['weather'][0]['description'];
          }
        }

        processedForecasts.add({
          'dt': DateTime.parse(date).millisecondsSinceEpoch ~/ 1000,
          'temp': {'max': maxTemp, 'min': minTemp},
          'weather': [
            {
              'id': mostFrequentWeatherId,
              'icon': mostFrequentIcon,
              'description': mostFrequentDescription,
            },
          ],
        });
      }
    });

    return processedForecasts;
  }

  /// **ACTION**: This method is updated to parse the new data structure.
  String _buildWeatherSummaryPrompt() {
    if (_currentWeather == null || _dailyForecast == null) {
      return '';
    }
    final lang = widget.languageCode;
    final currentTemp = _currentWeather!['main']['temp'].round();
    final currentCondition = _currentWeather!['weather'][0]['description'];
    String prompt =
        "Today's weather is $currentTemp°C with $currentCondition. Forecast for the next 7 days: ";

    for (final day in _dailyForecast!) {
      final date = DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);
      final dayName = DateFormat('EEEE', lang).format(date);
      final maxTemp = day['temp']['max'].round();
      final minTemp = day['temp']['min'].round();
      final dayDesc = day['weather'][0]['description'];
      prompt += "$dayName, $dayDesc, high $maxTemp°, low $minTemp°. ";
    }
    return prompt;
  }

  Future<void> _speakWeatherSummary() async {
    if (_isSpeaking || _currentWeather == null) return;
    try {
      setState(() => _isSpeaking = true);
      final prompt = _buildWeatherSummaryPrompt();
      if (prompt.isEmpty) throw Exception("Could not build prompt.");
      final summary = await _geminiService.generateWeatherSummary(
        prompt: prompt,
        languageCode: widget.languageCode,
      );
      final textToSpeak = summary ?? prompt;
      if (mounted) {
        String ttsLang = widget.languageCode;
        if (widget.languageCode == 'hi') ttsLang = 'hi-IN';
        if (widget.languageCode == 'en') ttsLang = 'en-US';
        await _flutterTts.setLanguage(ttsLang);
        await _flutterTts.speak(textToSpeak);
      }
    } catch (e) {
      debugPrint("Error in _speakWeatherSummary: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              weatherStrings[widget.languageCode]!['ai_summary_error']!,
            ),
          ),
        );
        setState(() => _isSpeaking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings =
        weatherStrings[widget.languageCode] ?? weatherStrings['en']!;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/agriculture_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.2),
            BlendMode.darken,
          ),
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            strings['weather_title']!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            if (_currentWeather != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _speakWeatherSummary,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isSpeaking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: 28,
                              ),
                        const SizedBox(width: 8),
                        Text(
                          strings['speak_weather_summary']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: FutureBuilder<void>(
            future: _dataLoaderCompleter.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(strings['loading']!),
                    ],
                  ),
                );
              }
              if (snapshot.hasError || _error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error ?? snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentWeatherCard(strings),
                    const SizedBox(height: 24),
                    Text(
                      strings['daily_forecast']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDailyForecastList(strings),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// **ACTION**: This widget is updated to parse the new data structure.
  Widget _buildCurrentWeatherCard(Map<String, String> strings) {
    if (_currentWeather == null) return const SizedBox.shrink();
    final temp = _currentWeather!['main']['temp'].round();
    final feelsLike = _currentWeather!['main']['feels_like'].round();
    final description = _currentWeather!['weather'][0]['description'];
    final iconCode = _currentWeather!['weather'][0]['icon'];
    final humidity = _currentWeather!['main']['humidity'];
    final windSpeed = (_currentWeather!['wind']['speed'] as num)
        .toStringAsFixed(1);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              strings['current_weather']!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    'https://openweathermap.org/img/wn/$iconCode@2x.png',
                    errorBuilder: (c, o, s) =>
                        const Icon(Icons.cloud, size: 80, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$temp°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWeatherDetail(
                    Icons.thermostat,
                    strings['feels_like']!,
                    '$feelsLike°C',
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  _buildWeatherDetail(
                    Icons.water_drop,
                    strings['humidity']!,
                    '$humidity%',
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  _buildWeatherDetail(
                    Icons.air,
                    strings['wind_speed']!,
                    '$windSpeed m/s',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **ACTION**: This widget is updated to parse the new data structure.
  Widget _buildDailyForecastList(Map<String, String> strings) {
    if (_dailyForecast == null || _dailyForecast!.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dailyForecast!.length,
      itemBuilder: (context, index) {
        final item = _dailyForecast![index];
        final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final dayName = DateFormat('EEEE', widget.languageCode).format(date);
        final maxTemp = item['temp']['max'].round();
        final minTemp = item['temp']['min'].round();
        final iconCode = item['weather'][0]['icon'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    'https://openweathermap.org/img/wn/$iconCode@2x.png',
                    errorBuilder: (c, o, s) =>
                        Icon(Icons.cloud, size: 30, color: Colors.blue[300]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['weather'][0]['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 16,
                          color: Colors.red[400],
                        ),
                        Text(
                          ' $maxTemp°',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: 16,
                          color: Colors.blue[400],
                        ),
                        Text(
                          ' $minTemp°',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue[700], size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.2),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
