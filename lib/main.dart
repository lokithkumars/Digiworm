import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// Firebase removed: import 'package:firebase_core/firebase_core.dart';
// Firebase removed: import 'firebase_options.dart';
// Firebase removed: import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';

// Crop options in local languages
final Map<String, List<String>> cropOptions = {
  'hi': [
    'चावल',
    'गेहूं',
    'मक्का',
    'गन्ना',
    'कपास',
    'दलहन',
    'सब्जियां',
    'टमाटर',
    'आलू',
    'प्याज',
    'मिर्च',
    'बैंगन',
    'पत्ता गोभी',
    'फूल गोभी',
    'गाजर',
    'फली',
    'मटर',
    'पालक',
    'भिंडी',
    'कद्दू',
    'मूली',
    'केला',
    'आम',
    'पपीता',
    'अमरूद',
    'संतरा',
    'नींबू',
    'अंगूर',
    'सेब',
    'अनार',
    'तरबूज',
    'खरबूजा',
    'कटहल',
    'चीकू',
    'सीताफल',
    'नारियल',
    'सुपारी',
    'कॉफी',
    'चाय',
    'रबर',
    'सूरजमुखी',
    'मूंगफली',
    'सोयाबीन',
    'तिल',
    'सरसों',
    'अलसी',
    'जूट',
    'शक्कर बीट',
    'तंबाकू',
    'अन्य',
  ],
  'en': [
    'Rice',
    'Wheat',
    'Maize',
    'Sugarcane',
    'Cotton',
    'Pulses',
    'Vegetables',
    'Tomato',
    'Potato',
    'Onion',
    'Chili',
    'Brinjal',
    'Cabbage',
    'Cauliflower',
    'Carrot',
    'Beans',
    'Peas',
    'Spinach',
    'Okra',
    'Pumpkin',
    'Radish',
    'Banana',
    'Mango',
    'Papaya',
    'Guava',
    'Orange',
    'Lemon',
    'Grapes',
    'Apple',
    'Pomegranate',
    'Watermelon',
    'Muskmelon',
    'Jackfruit',
    'Sapota',
    'Custard Apple',
    'Coconut',
    'Arecanut',
    'Coffee',
    'Tea',
    'Rubber',
    'Sunflower',
    'Groundnut',
    'Soybean',
    'Sesame',
    'Mustard',
    'Linseed',
    'Jute',
    'Sugar beet',
    'Tobacco',
    'Other',
  ],
  'kn': [
    'ಅಕ್ಕಿ',
    'ಗೋಧಿ',
    'ಜೋಳ',
    'ಸಕ್ಕರೆ',
    'ಹತ್ತಿ',
    'ಕಾಳುಗಳು',
    'ತರಕಾರಿಗಳು',
    'ಟೊಮೇಟೊ',
    'ಆಲೂಗಡ್ಡೆ',
    'ಈರುಳ್ಳಿ',
    'ಮೆಣಸು',
    'ಬದನೆಕಾಯಿ',
    'ಎಲೆಕೋಸು',
    'ಹೂಕೋಸು',
    'ಕ್ಯಾರೆಟ್',
    'ಹುರಳಿಕಾಯಿ',
    'ಬಟಾಣಿ',
    'ಪಾಲಕ್',
    'ಬೆಂಡೆಕಾಯಿ',
    'ಕುಂಬಳಕಾಯಿ',
    'ಮೂಲಂಗಿ',
    'ಬಾಳೆಹಣ್ಣು',
    'ಮಾವು',
    'ಪಪಾಯಿ',
    'ಸೀಬೆ',
    'ಕಿತ್ತಳೆ',
    'ನಿಂಬೆ',
    'ದ್ರಾಕ್ಷಿ',
    'ಸೇಬು',
    'ದಾಳಿಂಬೆ',
    'ಕಲ್ಲಂಗಡಿ',
    'ದೋಣಂಗಡಿ',
    'ಹಲಸಿನಹಣ್ಣು',
    'ಚಿಕ್ಕು',
    'ಸೀತಾಫಲ',
    'ತೆಂಗಿನಕಾಯಿ',
    'ಅಡಿಕೆ',
    'ಕಾಫಿ',
    'ಚಹಾ',
    'ರಬ್ಬರ್',
    'ಸೂರ್ಯಕಾಂತಿ',
    'ನಿಲಕ್ಕಟಲೆ',
    'ಸೊಯಾಬೀನ್',
    'ಎಳ್ಳು',
    'ಸಾಸಿವೆ',
    'ಅಲಸಿ',
    'ಜ್ಯೂಟ್',
    'ಸಕ್ಕರೆ ಬೀಟ್',
    'ಪೋಗರು',
    'ಇತರೆ',
  ],
  'ta': [
    'அரிசி',
    'கோதுமை',
    'சோளம்',
    'சர்க்கரை',
    'பருத்தி',
    'பயறு',
    'காய்கறிகள்',
    'தக்காளி',
    'உருளைக்கிழங்கு',
    'வெங்காயம்',
    'மிளகாய்',
    'கத்திரிக்காய்',
    'முட்டைகோஸ்',
    'பூக்கோஸ்',
    'கேரட்',
    'பீன்ஸ்',
    'பட்டாணி',
    'கீரை',
    'வெண்டை',
    'பூசணிக்காய்',
    'முள்ளங்கி',
    'வாழை',
    'மாம்பழம்',
    'பப்பாளி',
    'கொய்யா',
    'ஆரஞ்சு',
    'எலுமிச்சை',
    'திராட்சை',
    'ஆப்பிள்',
    'மாதுளை',
    'தர்பூசணி',
    'முலாம்பழம்',
    'பலாப்பழம்',
    'சப்போட்டா',
    'சீதாப்பழம்',
    'தேங்காய்',
    'பாக்கு',
    'காப்பி',
    'டீ',
    'ரப்பர்',
    'சூரியகாந்தி',
    'நிலக்கடலை',
    'சோயாபீன்',
    'எள்ளு',
    'கடுகு',
    'ஆல்சி',
    'ஜூட்',
    'சர்க்கரை பீட்',
    'புகையிலை',
    'மற்றவை',
  ],
  'te': [
    'బియ్యం',
    'గోధుమ',
    'మక్కజొన్న',
    'చెక్కెర',
    'పత్తి',
    'పప్పులు',
    'కూరగాయలు',
    'టమాట',
    'బంగాళదుంప',
    'ఉల్లిపాయ',
    'మిరప',
    'వంకాయ',
    'క్యాబేజీ',
    'కౌలీఫ్లవర్',
    'కారెట్',
    'బీన్స్',
    'పెసర',
    'పాలకూర',
    'బెండకాయ',
    'గుమ్మడికాయ',
    'ముల్లంగి',
    'అరటి',
    'మామిడి',
    'బొప్పాయి',
    'జామ',
    'నారింజ',
    'నిమ్మ',
    'ద్రాక್ష',
    'ఆపిల్',
    'దానిమ్మ',
    'పుచ్చకాయ',
    'కర్బూజ',
    'పనస',
    'సపోటా',
    'సీతాఫలం',
    'కొబ్బరి',
    'పుగాకు',
    'కాఫీ',
    'టీ',
    'రబ್బరు',
    'సూర్యకాంతి',
    'పల్లీలు',
    'సోయాబీన్',
    'నువ్వులు',
    'ఆవాలు',
    'ఆలసి',
    'జూట్',
    'చక్కెర బీట్',
    'పొగాకు',
    'ఇతర',
  ],
};

const Map<String, Map<String, String>> localizedStrings = {
  'hi': {
    'select_language': 'कृपया अपनी भाषा चुनें:',
    'name_prompt': 'आपका नाम क्या है?',
    'name_label': 'नाम',
    'phone_prompt': 'आपका फ़ोन नंबर क्या है?',
    'phone_label': 'फ़ोन नंबर',
    'land_prompt': 'आपकी भूमि का विवरण क्या है?',
    'land_label': 'भूमि विवरण',
    'crops_prompt': 'आप कौन-कौन सी फसलें उगाते हैं?',
    'crops_label': 'उगाई गई फसलें',
    'next': 'आगे',
    'submit': 'जमा करें',
    'select_language_title': 'भाषा चुनें',
    'enter_name_title': 'नाम दर्ज करें',
    'enter_phone_title': 'फ़ोन नंबर दर्ज करें',
    'enter_land_title': 'भूमि विवरण दर्ज करें',
    'enter_crops_title': 'फसलें दर्ज करें',
  },
  'en': {
    'select_language': 'Please select your language:',
    'name_prompt': 'What is your name?',
    'name_label': 'Name',
    'phone_prompt': 'What is your phone number?',
    'phone_label': 'Phone Number',
    'land_prompt': 'What are your landholdings?',
    'land_label': 'Landholdings',
    'crops_prompt': 'What crops do you grow?',
    'crops_label': 'Crops Grown',
    'next': 'Next',
    'submit': 'Submit',
    'select_language_title': 'Select Language',
    'enter_name_title': 'Enter Name',
    'enter_phone_title': 'Enter Phone Number',
    'enter_land_title': 'Enter Landholdings',
    'enter_crops_title': 'Enter Crops Grown',
  },
  'ta': {
    'select_language': 'தயவுசெய்து உங்கள் மொழியை தேர்ந்தெடுக்கவும்:',
    'name_prompt': 'உங்கள் பெயர் என்ன?',
    'name_label': 'பெயர்',
    'phone_prompt': 'உங்கள் தொலைபேசி எண் என்ன?',
    'phone_label': 'தொலைபேசி எண்',
    'land_prompt': 'உங்கள் நிலம் விவரங்கள்?',
    'land_label': 'நிலம் விவரங்கள்',
    'crops_prompt': 'நீங்கள் எந்த பயிர்கள் வளர்க்கிறீர்கள்?',
    'crops_label': 'வளர்க்கும் பயிர்கள்',
    'next': 'அடுத்தது',
    'submit': 'சமர்ப்பிக்கவும்',
    'select_language_title': 'மொழி தேர்வு',
    'enter_name_title': 'பெயரை உள்ளிடவும்',
    'enter_phone_title': 'தொலைபேசி எண்ணை உள்ளிடவும்',
    'enter_land_title': 'நில விவரங்களை உள்ளிடவும்',
    'enter_crops_title': 'பயிர்களை உள்ளிடவும்',
  },
  'kn': {
    'select_language': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ:',
    'name_prompt': 'ನಿಮ್ಮ ಹೆಸರು ಏನು?',
    'name_label': 'ಹೆಸರು',
    'phone_prompt': 'ನಿಮ್ಮ ಫೋನ್ ಸಂಖ್ಯೆ ಏನು?',
    'phone_label': 'ಫೋನ್ ಸಂಖ್ಯೆ',
    'land_prompt': 'ನಿಮ್ಮ ಭೂಮಿಯ ವಿವರಗಳು?',
    'land_label': 'ಭೂಮಿಯ ವಿವರಗಳು',
    'crops_prompt': 'ನೀವು ಯಾವ ಬೆಳೆಗಳನ್ನು ಬೆಳೆಸುತ್ತೀರಿ?',
    'crops_label': 'ಬೆಳೆಗಳು',
    'next': 'ಮುಂದೆ',
    'submit': 'ಸಲ್ಲಿಸು',
    'select_language_title': 'ಭಾಷೆ ಆಯ್ಕೆ',
    'enter_name_title': 'ಹೆಸರು ನಮೂದಿಸಿ',
    'enter_phone_title': 'ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ',
    'enter_land_title': 'ಭೂಮಿಯ ವಿವರಗಳು ನಮೂದಿಸಿ',
    'enter_crops_title': 'ಬೆಳೆಗಳು ನಮೂದಿಸಿ',
  },
  'te': {
    'select_language': 'దయచేసి మీ భాషను ఎంచుకోండి:',
    'name_prompt': 'మీ పేరు ఏమిటి?',
    'name_label': 'పేరు',
    'phone_prompt': 'మీ ఫోన్ నంబర్ ఏమిటి?',
    'phone_label': 'ఫోన్ నంబర్',
    'land_prompt': 'మీ భూమి వివరాలు?',
    'land_label': 'భూమి వివరాలు',
    'crops_prompt': 'మీరు ఎలాంటి పంటలు పెంచుతున్నారు?',
    'crops_label': 'పంటలు',
    'next': 'తరువాత',
    'submit': 'సమర్పించండి',
    'select_language_title': 'భాషను ఎంచుకోండి',
    'enter_name_title': 'పేరు నమోదు చేయండి',
    'enter_phone_title': 'ఫోన్ నంబర్ నమోదు చేయండి',
    'enter_land_title': 'భూమి వివరాలు నమోదు చేయండి',
    'enter_crops_title': 'పంటలు నమోదు చేయండి',
  },
};

const Map<String, String> ttsLocales = {
  'hi': 'hi-IN',
  'en': 'en-US',
  'kn': 'kn-IN',
  'ta': 'ta-IN',
  'te': 'te-IN',
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase removed: await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DigiwormApp());
}

class DigiwormApp extends StatelessWidget {
  const DigiwormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digiworm',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const LanguageSelectionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(localizedStrings['en']!['select_language_title']!),
          backgroundColor: Colors.green.withOpacity(0.8),
          elevation: 0,
        ),
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, size: 48, color: Colors.green[700]),
                  const SizedBox(height: 16),
                  Text(
                    localizedStrings['en']!['select_language']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ...['en', 'hi', 'ta', 'kn', 'te'].map(
                    (code) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NameInputPage(languageCode: code),
                            ),
                          );
                        },
                        child: Text(
                          code == 'en'
                              ? 'English'
                              : code == 'hi'
                              ? 'Hindi'
                              : code == 'ta'
                              ? 'Tamil'
                              : code == 'kn'
                              ? 'Kannada'
                              : 'Telugu',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NameInputPage extends StatefulWidget {
  final String languageCode;
  const NameInputPage({super.key, required this.languageCode});

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final TextEditingController _controller = TextEditingController();
  late FlutterTts _tts;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _speakPrompt();
  }

  Future<void> _speakPrompt() async {
    await _tts.setLanguage(ttsLocales[widget.languageCode] ?? 'en-US');
    await _tts.speak(localizedStrings[widget.languageCode]!['name_prompt']!);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await stt.SpeechToText().initialize();
      if (available) {
        setState(() => _isListening = true);
        stt.SpeechToText().listen(
          localeId: widget.languageCode,
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      stt.SpeechToText().stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            localizedStrings[widget.languageCode]!['enter_name_title']!,
          ),
          backgroundColor: Colors.green.withOpacity(0.8),
          elevation: 0,
        ),
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 48, color: Colors.green[700]),
                  const SizedBox(height: 16),
                  Text(
                    localizedStrings[widget.languageCode]!['name_prompt']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText:
                          localizedStrings[widget.languageCode]!['name_label']!,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.green[700],
                        ),
                        onPressed: _listen,
                        tooltip: 'Record',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_controller.text.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Please enter your name.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneInputPage(
                            languageCode: widget.languageCode,
                            name: _controller.text,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      localizedStrings[widget.languageCode]!['next']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PhoneInputPage extends StatefulWidget {
  final String languageCode;
  final String name;
  const PhoneInputPage({
    super.key,
    required this.languageCode,
    required this.name,
  });

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final TextEditingController _controller = TextEditingController();
  late FlutterTts _tts;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _speakPrompt();
  }

  Future<void> _speakPrompt() async {
    await _tts.setLanguage(ttsLocales[widget.languageCode] ?? 'en-US');
    await _tts.speak(localizedStrings[widget.languageCode]!['phone_prompt']!);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await stt.SpeechToText().initialize();
      if (available) {
        setState(() => _isListening = true);
        stt.SpeechToText().listen(
          localeId: widget.languageCode,
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      stt.SpeechToText().stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            localizedStrings[widget.languageCode]!['enter_phone_title']!,
          ),
          backgroundColor: Colors.green.withOpacity(0.8),
          elevation: 0,
        ),
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 48, color: Colors.green[700]),
                  const SizedBox(height: 16),
                  Text(
                    localizedStrings[widget.languageCode]!['phone_prompt']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText:
                          localizedStrings[widget
                              .languageCode]!['phone_label']!,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.green[700],
                        ),
                        onPressed: _listen,
                        tooltip: 'Record',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_controller.text.trim().isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                              'Please enter your phone number.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LandholdingsInputPage(
                            languageCode: widget.languageCode,
                            name: widget.name,
                            phone: _controller.text,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      localizedStrings[widget.languageCode]!['next']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LandholdingsInputPage extends StatefulWidget {
  final String languageCode;
  final String name;
  final String phone;
  const LandholdingsInputPage({
    super.key,
    required this.languageCode,
    required this.name,
    required this.phone,
  });

  @override
  State<LandholdingsInputPage> createState() => _LandholdingsInputPageState();
}

class _LandholdingsInputPageState extends State<LandholdingsInputPage> {
  late FlutterTts _tts;
  int? _selectedAcres;
  final List<int> _acresOptions = [1, 2, 3, 4, 5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _speakPrompt();
  }

  Future<void> _speakPrompt() async {
    await _tts.setLanguage(ttsLocales[widget.languageCode] ?? 'en-US');
    await _tts.speak(localizedStrings[widget.languageCode]!['land_prompt']!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            localizedStrings[widget.languageCode]!['enter_land_title']!,
          ),
          backgroundColor: Colors.green.withOpacity(0.8),
          elevation: 0,
        ),
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.agriculture, size: 48, color: Colors.green[700]),
                  const SizedBox(height: 16),
                  Text(
                    localizedStrings[widget.languageCode]!['land_prompt']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    value: _selectedAcres,
                    decoration: InputDecoration(
                      labelText:
                          localizedStrings[widget
                              .languageCode]!['land_label']! +
                          ' (acres)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      ..._acresOptions.map(
                        (acres) => DropdownMenuItem(
                          value: acres,
                          child: Text('$acres'),
                        ),
                      ),
                      const DropdownMenuItem(value: -1, child: Text('Other')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedAcres = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_selectedAcres == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                              'Please select your landholdings.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CropsInputPage(
                            languageCode: widget.languageCode,
                            name: widget.name,
                            phone: widget.phone,
                            land: _selectedAcres == -1
                                ? 'Other'
                                : _selectedAcres.toString(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      localizedStrings[widget.languageCode]!['next']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CropsInputPage extends StatefulWidget {
  final String languageCode;
  final String name;
  final String phone;
  final String land;
  const CropsInputPage({
    super.key,
    required this.languageCode,
    required this.name,
    required this.phone,
    required this.land,
  });

  @override
  State<CropsInputPage> createState() => _CropsInputPageState();
}

class _CropsInputPageState extends State<CropsInputPage> {
  late FlutterTts _tts;
  List<String> _selectedCrops = [];
  String? _otherCrop;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _speakPrompt();
  }

  Future<void> _listenForCrops() async {
    if (!_isListening) {
      bool available = await stt.SpeechToText().initialize();
      if (available) {
        setState(() => _isListening = true);
        await stt.SpeechToText().listen(
          localeId: widget.languageCode,
          onResult: (result) {
            setState(() => _isListening = false);
            String spoken = result.recognizedWords.trim().toLowerCase();
            final cropsList =
                cropOptions[widget.languageCode] ?? cropOptions['en']!;
            // Try to match spoken text to crop options
            List<String> matched = cropsList.where((crop) {
              return crop.toLowerCase() == spoken ||
                  crop.toLowerCase().contains(spoken) ||
                  spoken.contains(crop.toLowerCase());
            }).toList();
            if (matched.isNotEmpty) {
              setState(() {
                for (var crop in matched) {
                  if (!_selectedCrops.contains(crop)) {
                    _selectedCrops.add(crop);
                  }
                }
              });
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Not Found'),
                  content: Text('No matching crop found for "$spoken".'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      stt.SpeechToText().stop();
    }
  }

  Future<void> _speakPrompt() async {
    await _tts.setLanguage(ttsLocales[widget.languageCode] ?? 'en-US');
    await _tts.speak(localizedStrings[widget.languageCode]!['crops_prompt']!);
  }

  // Firebase removed: _saveToFirebase and Firestore usage
  // Future<void> _saveToFirebase() async {
  //   String cropsValue;
  //   if (_selectedCrops.contains(cropOptions[widget.languageCode]!.last)) {
  //     cropsValue =
  //         (_selectedCrops..remove(cropOptions[widget.languageCode]!.last)).join(
  //           ', ',
  //         );
  //     if (_otherCrop != null && _otherCrop!.trim().isNotEmpty) {
  //       cropsValue += ', Other: ${_otherCrop!.trim()}';
  //     }
  //   } else {
  //     cropsValue = _selectedCrops.join(', ');
  //   }
  //   await FirebaseFirestore.instance.collection('farmers').add({
  //     'name': widget.name,
  //     'phone': widget.phone,
  //     'landholdings': widget.land,
  //     'crops': cropsValue,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final cropsList = cropOptions[widget.languageCode] ?? cropOptions['en']!;
    final otherLabel = cropsList.last;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          localizedStrings[widget.languageCode]!['enter_crops_title']!,
        ),
        backgroundColor: Colors.green.withOpacity(0.8),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/agriculture_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.green.withOpacity(0.18),
              BlendMode.srcATop,
            ),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    localizedStrings[widget.languageCode]!['crops_prompt']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                        label: Text(
                          _isListening ? 'Listening...' : 'Speak Crops',
                        ),
                        onPressed: _listenForCrops,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3.5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: cropsList.length,
                      itemBuilder: (context, idx) {
                        final crop = cropsList[idx];
                        final isOther = crop == otherLabel;
                        final selected = _selectedCrops.contains(crop);
                        return ChoiceChip(
                          label: Text(
                            crop,
                            style: const TextStyle(fontSize: 16),
                          ),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedCrops.add(crop);
                              } else {
                                _selectedCrops.remove(crop);
                                if (isOther) _otherCrop = null;
                              }
                            });
                          },
                          selectedColor: Colors.green[300],
                          backgroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_selectedCrops.contains(otherLabel)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: otherLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _otherCrop = val;
                        });
                      },
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () async {
                      if (_selectedCrops.isEmpty ||
                          (_selectedCrops.contains(otherLabel) &&
                              (_otherCrop == null ||
                                  _otherCrop!.trim().isEmpty))) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Please select crops grown.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      // Firebase removed: try { await _saveToFirebase(); } catch (e) { ... }
                      // Firebase removed: finally { ... }
                      // Navigate to the dashboard regardless of success or failure
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(
                            languageCode: widget.languageCode,
                            farmerName: widget.name,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      localizedStrings[widget.languageCode]!['submit']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
