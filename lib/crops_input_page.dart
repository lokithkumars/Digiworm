import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; // Import cropOptions, localizedStrings, and ttsLocales

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
  late stt.SpeechToText _speech;
  final List<String> _selectedCrops = [];
  String? _otherCrop;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _speech = stt.SpeechToText();
    _speakPrompt();
  }

  Future<void> _listenForCrops() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: widget.languageCode,
          onResult: (result) {
            setState(() => _isListening = false);
            String spoken = result.recognizedWords.trim().toLowerCase();
            final cropsList =
                cropOptions[widget.languageCode] ?? cropOptions['en']!;
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
      _speech.stop();
    }
  }

  Future<void> _speakPrompt() async {
    await _tts.setLanguage(ttsLocales[widget.languageCode] ?? 'en-US');
    await _tts.speak(localizedStrings[widget.languageCode]!['crops_prompt']!);
  }

  Future<void> _saveToFirebase() async {
    String cropsValue;
    if (_selectedCrops.contains(cropOptions[widget.languageCode]!.last)) {
      cropsValue =
          (_selectedCrops..remove(cropOptions[widget.languageCode]!.last)).join(
            ', ',
          );
      if (_otherCrop != null && _otherCrop!.trim().isNotEmpty) {
        cropsValue += ', Other: ${_otherCrop!.trim()}';
      }
    } else {
      cropsValue = _selectedCrops.join(', ');
    }
    await FirebaseFirestore.instance.collection('farmers').add({
      'name': widget.name,
      'phone': widget.phone,
      'landholdings': widget.land,
      'crops': cropsValue,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

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
            image: const AssetImage('assets/agriculture_bg.jpg'),
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
                      await _saveToFirebase();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Your data has been saved!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
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
