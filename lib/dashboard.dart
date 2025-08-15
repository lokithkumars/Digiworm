import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'yearly_plan_screen.dart';
import 'scheme_page.dart';
import 'weather.dart';
import 'Screens/disease_prediction_screen.dart';

// Add these localized strings for dashboard
const Map<String, Map<String, String>> dashboardStrings = {
  'hi': {
    'dashboard_title': 'डैशबोर्ड',
    'weather': 'मौसम',
    'crop_disease': 'फसल रोग',
    'market_details': 'बाजार विवरण',
    'govt_schemes': 'सरकारी योजनाएं',
    'query_hint': 'अपना प्रश्न यहाँ पूछें...',
    'ask_question': 'प्रश्न पूछें',
    'welcome_back': 'वापस स्वागत है',
    'weather_desc': 'आज का मौसम और पूर्वानुमान',
    'disease_desc': 'फसल रोग की पहचान और समाधान',
    'market_desc': 'फसल की कीमतें और बाजार की जानकारी',
    'schemes_desc': 'किसानों के लिए सरकारी योजनाएं',
  },
  'en': {
    'dashboard_title': 'Dashboard',
    'weather': 'Weather',
    'crop_disease': 'Crop Disease',
    'market_details': 'Yearly Crop Plan',
    'govt_schemes': 'Government Schemes',
    'query_hint': 'Ask your question here...',
    'ask_question': 'Ask Question',
    'welcome_back': 'Welcome Back',
    'weather_desc': 'Today\'s weather and forecast',
    'disease_desc': 'Crop disease identification and solutions',
    'market_desc': 'Smart seasonal crop planning guide',
    'schemes_desc': 'Government schemes for farmers',
  },
  'kn': {
    'dashboard_title': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
    'weather': 'ಹವಾಮಾನ',
    'crop_disease': 'ಬೆಳೆ ರೋಗ',
    'market_details': 'ಮಾರುಕಟ್ಟೆ ವಿವರಗಳು',
    'govt_schemes': 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
    'query_hint': 'ನಿಮ್ಮ ಪ್ರಶ್ನೆಯನ್ನು ಇಲ್ಲಿ ಕೇಳಿ...',
    'ask_question': 'ಪ್ರಶ್ನೆ ಕೇಳಿ',
    'welcome_back': 'ಸ್ವಾಗತ',
    'weather_desc': 'ಇಂದಿನ ಹವಾಮಾನ ಮತ್ತು ಮುನ್ಸೂಚನೆ',
    'disease_desc': 'ಬೆಳೆ ರೋಗ ಗುರುತಿಸುವಿಕೆ ಮತ್ತು ಪರಿಹಾರಗಳು',
    'market_desc': 'ಬೆಳೆ ಬೆಲೆಗಳು ಮತ್ತು ಮಾರುಕಟ್ಟೆ ಮಾಹಿತಿ',
    'schemes_desc': 'ರೈತರಿಗೆ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
  },
  'ta': {
    'dashboard_title': 'டாஷ்போர்டு',
    'weather': 'வானிலை',
    'crop_disease': 'பயிர் நோய்',
    'market_details': 'சந்தை விவரங்கள்',
    'govt_schemes': 'அரசு திட்டங்கள்',
    'query_hint': 'உங்கள் கேள்வியை இங்கே கேளுங்கள்...',
    'ask_question': 'கேள்வி கேளுங்கள்',
    'welcome_back': 'வரவேற்கிறோம்',
    'weather_desc': 'இன்றைய வானிலை மற்றும் முன்னறிவிப்பு',
    'disease_desc': 'பயிர் நோய் அடையாளம் மற்றும் தீர்வுகள்',
    'market_desc': 'பயிர் விலைகள் மற்றும் சந்தை தகவல்',
    'schemes_desc': 'விவசாயிகளுக்கான அரசு திட்டங்கள்',
  },
  'te': {
    'dashboard_title': 'డాష్‌బోర్డ్',
    'weather': 'వాతావరణం',
    'crop_disease': 'పంట వ్యాధి',
    'market_details': 'మార్కెట్ వివరాలు',
    'govt_schemes': 'ప్రభుత్వ పథకాలు',
    'query_hint': 'మీ ప్రశ్నను ఇక్కడ అడగండి...',
    'ask_question': 'ప్రశ్న అడగండి',
    'welcome_back': 'స్వాగతం',
    'weather_desc': 'నేటి వాతావరణం మరియు సూచన',
    'disease_desc': 'పంట వ్యాధి గుర్తింపు మరియు పరిష్కారాలు',
    'market_desc': 'పంట ధరలు మరియు మార్కెట్ సమాచారం',
    'schemes_desc': 'రైతుల కోసం ప్రభుత్వ పథకాలు',
  },
};

class DashboardPage extends StatefulWidget {
  final String languageCode;
  final String farmerName;

  const DashboardPage({
    super.key,
    required this.languageCode,
    required this.farmerName,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _queryController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Position? _position; // Add this line

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get the current position
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _position = position; // Store the position
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: widget.languageCode,
          onResult: (result) {
            setState(() {
              _queryController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Widget _buildDashboardCard({
    required String title,
    required String description,
    required String imagePath, // Changed to use image path
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleQuery() {
    if (_queryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Here you can implement the query processing logic
    // For now, just show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Query Received'),
        content: Text(
          'Your question: "${_queryController.text}" has been received. Our AI will respond soon.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _queryController.clear();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings =
        dashboardStrings[widget.languageCode] ?? dashboardStrings['en']!;

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
          title: Text(
            strings['dashboard_title']!,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${strings['welcome_back']!}, ${widget.farmerName}',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Dashboard Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildDashboardCard(
                    title: strings['weather']!,
                    description: strings['weather_desc']!,
                    imagePath: 'assets/images/weather.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeatherPage(
                            languageCode: widget.languageCode,
                            currentPosition: _position,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: strings['crop_disease']!,
                    description: strings['disease_desc']!,
                    imagePath: 'assets/images/crop_disease.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DiseasePredictionScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: strings['market_details']!,
                    description: strings['market_desc']!,
                    imagePath: 'assets/images/market.jpg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YearlyPlanPage(
                            userState: "Maharashtra",
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: strings['govt_schemes']!,
                    description: strings['schemes_desc']!,
                    imagePath: 'assets/images/govt_scheme.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchemeDashboard(
                            languageCode: widget.languageCode,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Query Section
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Colors.green[700],
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            strings['ask_question']!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _queryController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: strings['query_hint']!,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              icon: const Icon(Icons.send),
                              label: Text(
                                strings['ask_question']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              onPressed: _handleQuery,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? Colors.red[400]
                                  : Colors.green[400],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: _listen,
                              tooltip: 'Voice Input',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
