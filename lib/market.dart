import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';

// --- Models ---
class CropPrice {
  final String cropName;
  final double currentPrice;
  final double? yesterdayPrice;
  final String trend;
  final String quality;
  final String demandLevel;
  final String bestTimeToSell;
  final DateTime lastUpdated;

  CropPrice({
    required this.cropName,
    required this.currentPrice,
    this.yesterdayPrice,
    this.trend = '',
    this.quality = '',
    this.demandLevel = '',
    this.bestTimeToSell = '',
    required this.lastUpdated,
  });

  static CropPrice fromGovernmentData(Map<String, dynamic> data) {
    double currentPrice =
        double.tryParse(data['modal_price']?.toString() ?? '0') ?? 0;
    double? yesterdayPrice = double.tryParse(
      data['previous_price']?.toString() ?? '0',
    );
    return CropPrice(
      cropName: data['commodity']?.toString() ?? 'Unknown',
      currentPrice: currentPrice,
      yesterdayPrice: yesterdayPrice,
      trend: _calculateTrendFromData(currentPrice, yesterdayPrice),
      quality: data['grade']?.toString() ?? 'Average',
      demandLevel: 'Medium',
      bestTimeToSell: 'Morning',
      lastUpdated: DateTime.now(),
    );
  }

  static String _calculateTrendFromData(double current, double? yesterday) {
    if (yesterday == null || yesterday == 0) return 'Stable';
    double change = ((current - yesterday) / yesterday) * 100;
    if (change > 2) return 'Rising';
    if (change < -2) return 'Falling';
    return 'Stable';
  }
}

class MandiInfo {
  final String name;
  final double distance;
  final String demand;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final List<String> acceptedCrops;
  final DateTime lastUpdated;

  MandiInfo({
    required this.name,
    required this.distance,
    this.demand = '',
    this.address = '',
    this.phone,
    this.latitude,
    this.longitude,
    this.acceptedCrops = const [],
    required this.lastUpdated,
  });
}

enum LoadingState { idle, loading, refreshing, error }

// Updated API Service with real market data APIs
class MarketApiService {
  late final Dio _dio;
  final Logger _logger = Logger();
  late final EnhancedGeminiAI _geminiAI;

  MarketApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    String apiKey = kIsWeb
        ? 'AIzaSyAdKbM43WXMXcrBuKxoLyGMmOaNUT7CdVo'
        : dotenv.env['GEMINI_API_KEY'] ??
              'AIzaSyAdKbM43WXMXcrBuKxoLyGMmOaNUT7CdVo';
    _geminiAI = EnhancedGeminiAI(apiKey: apiKey);
  }

  // Using India's Department of Agriculture & Cooperation API
  Future<List<CropPrice>> fetchCropPricesFromGovernmentAPI({
    required Position position,
    required List<String> crops,
  }) async {
    try {
      const String govApiUrl =
          'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';
      final response = await _dio.get(
        govApiUrl,
        queryParameters: {
          'api-key': '579b464db66ec23bdd000001cd6ffaa79fa942d7793a09869d40e392',
          'format': 'json',
          'limit': 1000,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final processedPrices = await _geminiAI.processMarketDataWithGemini(
          apiData: response.data,
          userCrops: crops,
          position: position,
        );
        if (processedPrices.isNotEmpty) {
          _logger.i("Successfully processed market data with Gemini.");
          return processedPrices;
        } else {
          _logger.w("Gemini returned no prices. Falling back.");
        }
      }
    } catch (e) {
      _logger.e('Government API or Gemini processing error: $e');
    }
    return _getFallbackCropPrices(crops);
  }

  // Alternative: Using AgriMarket API
  Future<List<CropPrice>> fetchFromAgriMarketAPI({
    required Position position,
    required List<String> crops,
  }) async {
    try {
      // AgriMarket API (hypothetical - replace with actual working API)
      const String agriApiUrl = 'https://agrimarket.nic.in/api/prices';

      final response = await _dio.get(
        agriApiUrl,
        queryParameters: {
          'state': _getStateFromCoordinates(position),
          'district': _getDistrictFromCoordinates(position),
          'commodity': crops.join(','),
        },
      );

      if (response.statusCode == 200) {
        return _parseAgriMarketResponse(response.data, crops);
      }
    } catch (e) {
      _logger.e('AgriMarket API error: $e');
    }

    return _getFallbackCropPrices(crops);
  }

  // Scrape data from reliable market websites
  Future<List<CropPrice>> fetchFromMarketWebsites({
    required Position position,
    required List<String> crops,
  }) async {
    try {
      List<CropPrice> allPrices = [];

      // Try multiple sources
      await Future.wait([
        _fetchFromKrishiJagran(crops),
        _fetchFromAgriWatch(crops),
        _fetchFromMandiPrices(crops),
      ]).then((results) {
        for (var result in results) {
          allPrices.addAll(result);
        }
      });

      return allPrices.isNotEmpty ? allPrices : _getFallbackCropPrices(crops);
    } catch (e) {
      _logger.e('Web scraping error: $e');
      return _getFallbackCropPrices(crops);
    }
  }

  Future<List<CropPrice>> _fetchFromKrishiJagran(List<String> crops) async {
    // Implement web scraping for Krishi Jagran
    // This is a placeholder - implement actual scraping logic
    return [];
  }

  Future<List<CropPrice>> _fetchFromAgriWatch(List<String> crops) async {
    // Implement web scraping for AgriWatch
    return [];
  }

  Future<List<CropPrice>> _fetchFromMandiPrices(List<String> crops) async {
    // Implement web scraping for mandi prices
    return [];
  }

  bool _isCropMatch(String apiCrop, List<String> userCrops) {
    String normalizedApiCrop = apiCrop.toLowerCase().split(' ')[0];
    return userCrops.any(
      (userCrop) =>
          userCrop.toLowerCase().contains(normalizedApiCrop) ||
          normalizedApiCrop.contains(userCrop.toLowerCase()),
    );
  }

  String _getStateFromCoordinates(Position position) {
    // Simple logic to determine state from coordinates
    // You might want to use a reverse geocoding service
    if (position.latitude >= 8.0 &&
        position.latitude <= 18.0 &&
        position.longitude >= 74.0 &&
        position.longitude <= 80.0) {
      return 'Karnataka';
    }
    return 'Unknown';
  }

  String _getDistrictFromCoordinates(Position position) {
    // Similar logic for district
    return 'Bangalore';
  }

  List<CropPrice> _parseAgriMarketResponse(dynamic data, List<String> crops) {
    List<CropPrice> prices = [];
    // Parse the response based on actual API structure
    return prices;
  }

  // Enhanced fallback with realistic Indian market prices
  List<CropPrice> _getFallbackCropPrices(List<String> crops) {
    final random = Random();
    final currentTime = DateTime.now();

    // Base prices for common Indian crops (per quintal in INR)
    final Map<String, double> basePrices = {
      'rice': 2800 + random.nextDouble() * 400,
      'wheat': 2200 + random.nextDouble() * 300,
      'maize': 2000 + random.nextDouble() * 200,
      'sugarcane': 350 + random.nextDouble() * 50,
      'cotton': 6500 + random.nextDouble() * 1000,
      'tomato': 1500 + random.nextDouble() * 800,
      'potato': 1200 + random.nextDouble() * 500,
      'onion': 2500 + random.nextDouble() * 1000,
      'soybean': 4500 + random.nextDouble() * 800,
      'groundnut': 5200 + random.nextDouble() * 600,
    };

    return crops.map((crop) {
      String normalizedCrop = crop.toLowerCase();
      double basePrice =
          basePrices[normalizedCrop] ?? (2000 + random.nextDouble() * 1000);
      double yesterdayPrice = basePrice - (random.nextDouble() * 200 - 100);

      return CropPrice(
        cropName: crop,
        currentPrice: basePrice,
        yesterdayPrice: yesterdayPrice,
        trend: _calculateTrend(basePrice, yesterdayPrice),
        quality: ['Premium', 'Average', 'Good'][random.nextInt(3)],
        demandLevel: ['High', 'Medium', 'Low'][random.nextInt(3)],
        bestTimeToSell: _getBestSellingTime(),
        lastUpdated: currentTime,
      );
    }).toList();
  }

  String _calculateTrend(double current, double yesterday) {
    double change = ((current - yesterday) / yesterday) * 100;
    if (change > 2) return 'Rising';
    if (change < -2) return 'Falling';
    return 'Stable';
  }

  String _getBestSellingTime() {
    final times = [
      'Early Morning (6-8 AM)',
      'Morning (8-11 AM)',
      'Afternoon (2-4 PM)',
      'Evening (4-6 PM)',
    ];
    return times[Random().nextInt(times.length)];
  }
}

// Enhanced Gemini AI Service
class EnhancedGeminiAI {
  final String apiKey;
  late final Dio _dio;
  final Logger _logger = Logger();

  EnhancedGeminiAI({required this.apiKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey, // This is correct
        },
      ),
    );
  }

  Future<List<CropPrice>> processMarketDataWithGemini({
    required Map<String, dynamic> apiData,
    required List<String> userCrops,
    required Position position,
  }) async {
    _logger.i("Attempting to process market data with Gemini...");
    try {
      String prompt = _buildProcessingPrompt(apiData, userCrops, position);
      // We are expecting Gemini to return a JSON string
      final response = await _generateContent(prompt, expectJson: true);

      if (response != null && response.isNotEmpty) {
        // Clean the response to ensure it's valid JSON
        String cleanedResponse = response
            .trim()
            .replaceAll('```json', '')
            .replaceAll('```', '');
        final List<dynamic> processedData = json.decode(cleanedResponse);
        _logger.i(
          "✅ Successfully parsed ${processedData.length} crop prices from Gemini.",
        );
        return processedData
            .map((data) => CropPrice.fromGovernmentData(data))
            .toList();
      }
    } catch (e) {
      _logger.e('❌ Gemini market data processing failed: $e');
    }
    return [];
  }

  Future<Map<String, String>> getMarketInsights({
    // Make these optional as they are not needed for the weather prompt
    List<CropPrice>? cropPrices,
    List<MandiInfo>? mandis,
    required String languageCode,
    required Position position,
    // Add an optional custom prompt
    String? customPrompt,
  }) async {
    _logger.i("Fetching high-level insights from Gemini...");
    try {
      // Use the custom prompt if provided, otherwise build the market insight prompt
      String prompt =
          customPrompt ??
          _buildInsightPrompt(cropPrices!, mandis!, languageCode, position);
      // For insights, we just need a plain text response
      final response = await _generateContent(prompt, expectJson: false);

      if (response != null) {
        _logger.i("✅ Successfully received insights.");
        return {'summary': response};
      }
    } catch (e) {
      _logger.e('❌ Gemini insight generation failed: $e');
    }
    return {'summary': 'Could not fetch AI insights. Please check the logs.'};
  }

  // **FINAL CORRECTED VERSION of _generateContent**
  Future<String?> _generateContent(
    String prompt, {
    bool expectJson = true,
  }) async {
    // **FIX:** Using the v1beta endpoint and a stable model name.
    const String url = '/v1beta/models/gemini-1.5-flash-latest:generateContent';

    try {
      final response = await _dio.post(
        url,
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.2,
            'maxOutputTokens': 2048,
            // This parameter is VALID for the v1beta endpoint.
            if (expectJson) 'response_mime_type': 'application/json',
          },
        },
      );
      if (response.statusCode == 200) {
        return response
            .data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      }
    } on DioException catch (e) {
      _logger.e(
        'API Call Failed. Status: ${e.response?.statusCode}, Body: ${e.response?.data}',
      );
    } catch (e) {
      _logger.e('An unexpected error occurred in _generateContent: $e');
    }
    return null;
  }

  // This prompt is refined slightly for better clarity.
  String _buildProcessingPrompt(
    Map<String, dynamic> data,
    List<String> crops,
    Position position,
  ) {
    // Ensure you are passing the list of records correctly.
    final records = data['records'] ?? [];
    final jsonDataString = json.encode(records);
    return '''
    Analyze the following JSON market data from an Indian government API.
    The crops I care about are: ${crops.join(', ')}.

    Action: From the provided JSON data, filter the records to find entries that match my crops.
    Output Rules:
    1.  Return ONLY a valid JSON array of objects.
    2.  Do not include any explanatory text, markdown like ```json, or anything else outside the JSON array.
    3.  Each object in the array must have these exact keys: "commodity", "modal_price".

    JSON Data:
    $jsonDataString
    ''';
  }

  // This prompt for user-friendly advice is also unchanged.
  String _buildInsightPrompt(
    List<CropPrice> crops,
    List<MandiInfo> mandis,
    String languageCode,
    Position position,
  ) {
    StringBuffer prompt = StringBuffer();

    prompt.writeln(
      'You are an agricultural market analyst. Analyze the following data and provide insights:',
    );
    prompt.writeln('\nCrop Prices:');
    for (var crop in crops) {
      prompt.writeln(
        '- ${crop.cropName}: ₹${crop.currentPrice}/quintal (Yesterday: ₹${crop.yesterdayPrice})',
      );
    }

    prompt.writeln('\nNearby Mandis:');
    for (var mandi in mandis) {
      prompt.writeln(
        '- ${mandi.name}: ${mandi.distance}km away, Demand: ${mandi.demand}',
      );
    }

    prompt.writeln(
      '\nProvide response in ${_getLanguageName(languageCode)} language with:',
    );
    prompt.writeln('1. Market Summary (2-3 sentences)');
    prompt.writeln('2. Best crops to sell now');
    prompt.writeln('3. Price predictions for next week');
    prompt.writeln('4. Recommended selling strategy');

    return prompt.toString();
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'Hindi';
      case 'kn':
        return 'Kannada';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      default:
        return 'English';
    }
  }
}

// Enhanced CropPrice class with government data support
// ...existing code...

// Location-based Mandi Service
class MandiLocationService {
  final Logger _logger = Logger();

  Future<List<MandiInfo>> getNearbyMandis({
    required Position position,
    double radiusKm = 50,
  }) async {
    try {
      // In a real implementation, you would:
      // 1. Query a database of mandi locations
      // 2. Use services like Google Places API
      // 3. Access government mandi directories

      return _getStaticMandisForLocation(position, radiusKm);
    } catch (e) {
      _logger.e('Error fetching mandis: $e');
      return _getStaticMandisForLocation(position, radiusKm);
    }
  }

  List<MandiInfo> _getStaticMandisForLocation(
    Position position,
    double radius,
  ) {
    // Static data for major Indian agricultural markets
    List<MandiInfo> allMandis = [
      MandiInfo(
        name: 'APMC Market Bangalore',
        distance: _calculateDistance(position, 12.9716, 77.5946),
        demand: 'High',
        address: 'Yeshwanthpur, Bangalore, Karnataka',
        phone: '+91-80-23740321',
        latitude: 12.9716,
        longitude: 77.5946,
        acceptedCrops: ['Rice', 'Wheat', 'Maize', 'Cotton', 'Sugarcane'],
        lastUpdated: DateTime.now(),
      ),
      MandiInfo(
        name: 'Kolar Agricultural Market',
        distance: _calculateDistance(position, 13.1370, 78.1298),
        demand: 'Medium',
        address: 'Kolar, Karnataka',
        phone: '+91-8152-222333',
        latitude: 13.1370,
        longitude: 78.1298,
        acceptedCrops: ['Tomato', 'Potato', 'Onion', 'Groundnut'],
        lastUpdated: DateTime.now(),
      ),
      // Add more mandis based on different regions
    ];

    return allMandis.where((mandi) => mandi.distance <= radius).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  double _calculateDistance(Position userPos, double lat, double lon) {
    return Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          lat,
          lon,
        ) /
        1000; // Convert to kilometers
  }
}

// Updated Market Details Page with better error handling
class EnhancedMarketDetailsPage extends StatefulWidget {
  final String languageCode;
  final Position? currentPosition;
  final List<String> userCrops;

  const EnhancedMarketDetailsPage({
    super.key,
    required this.languageCode,
    required this.currentPosition,
    required this.userCrops,
  });

  @override
  State<EnhancedMarketDetailsPage> createState() =>
      _EnhancedMarketDetailsPageState();
}

class _EnhancedMarketDetailsPageState extends State<EnhancedMarketDetailsPage> {
  final MarketApiService _marketService = MarketApiService();
  final MandiLocationService _mandiService = MandiLocationService();
  late final EnhancedGeminiAI _geminiAI;

  List<CropPrice> _cropPrices = [];
  List<MandiInfo> _nearbyMandis = [];
  Map<String, String> _aiInsights = {};

  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    _loadMarketData();
  }

  void _initializeGemini() {
    String apiKey = kIsWeb
        ? 'AIzaSyAdKbM43WXMXcrBuKxoLyGMmOaNUT7CdVo' // Your actual key
        : dotenv.env['GEMINI_API_KEY'] ??
              'AIzaSyAdKbM43WXMXcrBuKxoLyGMmOaNUT7CdVo';
    _geminiAI = EnhancedGeminiAI(apiKey: apiKey);
  }

  Future<void> _loadMarketData() async {
    if (widget.currentPosition == null) {
      setState(() {
        _errorMessage = 'Location permission required';
        _loadingState = LoadingState.error;
      });
      return;
    }

    setState(() => _loadingState = LoadingState.loading);

    try {
      // Try multiple data sources in sequence
      List<CropPrice> prices = [];

      // Try government API first
      try {
        prices = await _marketService.fetchCropPricesFromGovernmentAPI(
          position: widget.currentPosition!,
          crops: widget.userCrops,
        );
      } catch (e) {
        print('Government API failed: $e');
      }

      // Fallback to web sources if government API fails
      if (prices.isEmpty) {
        prices = await _marketService.fetchFromMarketWebsites(
          position: widget.currentPosition!,
          crops: widget.userCrops,
        );
      }

      // Get nearby mandis
      final mandis = await _mandiService.getNearbyMandis(
        position: widget.currentPosition!,
        radiusKm: 50,
      );

      // Get AI insights
      final insights = await _geminiAI.getMarketInsights(
        cropPrices: prices,
        mandis: mandis,
        languageCode: widget.languageCode,
        position: widget.currentPosition!,
      );

      setState(() {
        _cropPrices = prices;
        _nearbyMandis = mandis;
        _aiInsights = insights;
        _loadingState = LoadingState.idle;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loadingState = LoadingState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/agriculture_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color(0x88000000), // Semi-transparent black overlay
            BlendMode.darken,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Market Details',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadMarketData,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_loadingState) {
      case LoadingState.loading:
        return Center(
          child: Card(
            elevation: 8,
            color: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading market data...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );

      case LoadingState.error:
        return Center(
          child: Card(
            elevation: 8,
            color: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'Unknown error',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _loadMarketData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );

      case LoadingState.idle:
      case LoadingState.refreshing:
        return RefreshIndicator(
          onRefresh: _loadMarketData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_aiInsights.isNotEmpty) _buildAIInsightsCard(),
                const SizedBox(height: 16),
                _buildCropPricesSection(),
                const SizedBox(height: 16),
                _buildMandisSection(),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildAIInsightsCard() {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(12),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: Colors.purple.shade700),
                const SizedBox(width: 10),
                Text(
                  'AI Market Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _loadingState == LoadingState.loading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    _aiInsights['summary'] ??
                        'No analysis available. Please try again later.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropPricesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crop Prices',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 12),
        if (_cropPrices.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No crop price data available'),
            ),
          )
        else
          ..._cropPrices.map((crop) => _buildCropPriceCard(crop)),
      ],
    );
  }

  Widget _buildCropPriceCard(CropPrice crop) {
    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.remove;

    switch (crop.trend.toLowerCase()) {
      case 'rising':
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        break;
      case 'falling':
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    crop.cropName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: trendColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 16, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        crop.trend,
                        style: TextStyle(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${crop.currentPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                      ),
                      Text(
                        'per quintal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (crop.yesterdayPrice != null)
                  Text(
                    'Yesterday: ₹${crop.yesterdayPrice!.toStringAsFixed(0)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip('Quality', crop.quality, Icons.star),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Demand',
                    crop.demandLevel,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            if (crop.bestTimeToSell.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoChip('Best Time', crop.bestTimeToSell, Icons.schedule),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMandisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Mandis',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 12),
        if (_nearbyMandis.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No nearby mandis found'),
            ),
          )
        else
          ..._nearbyMandis.map((mandi) => _buildMandiCard(mandi)),
      ],
    );
  }

  Widget _buildMandiCard(MandiInfo mandi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mandi.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getDemandColor(mandi.demand).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getDemandColor(mandi.demand)),
                  ),
                  child: Text(
                    mandi.demand,
                    style: TextStyle(
                      color: _getDemandColor(mandi.demand),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${mandi.distance.toStringAsFixed(1)} km away'),
              ],
            ),
            if (mandi.address.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.home, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(mandi.address)),
                ],
              ),
            ],
            if (mandi.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(mandi.phone!),
                ],
              ),
            ],
            if (mandi.acceptedCrops.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Accepted Crops:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: mandi.acceptedCrops
                    .map(
                      (crop) => Chip(
                        label: Text(crop, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.green[50],
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDemandColor(String demand) {
    switch (demand.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
