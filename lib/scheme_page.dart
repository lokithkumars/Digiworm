import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dashboard.dart';

class SchemeDashboard extends StatefulWidget {
  final String languageCode;
  const SchemeDashboard({super.key, required this.languageCode});

  @override
  State<SchemeDashboard> createState() => _SchemeDashboardState();
}

class _SchemeDashboardState extends State<SchemeDashboard> {
  late FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    String ttsLang = widget.languageCode;
    if (widget.languageCode == 'hi') ttsLang = 'hi-IN';
    if (widget.languageCode == 'en') ttsLang = 'en-US';
    if (widget.languageCode == 'ta') ttsLang = 'ta-IN';
    if (widget.languageCode == 'te') ttsLang = 'te-IN';
    if (widget.languageCode == 'kn') ttsLang = 'kn-IN';
    await _tts.setLanguage(ttsLang);
  }

  Future<void> _speakSchemeDetails(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    await _tts.speak(text);
    setState(() => _isSpeaking = false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings =
        dashboardStrings[widget.languageCode] ?? dashboardStrings['en']!;
    final schemes =
        localizedSchemes[widget.languageCode] ?? localizedSchemes['en']!;
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
          title: Text(strings['govt_schemes'] ?? 'Government Schemes'),
          backgroundColor: Colors.green.withOpacity(0.8),
          elevation: 0,
        ),
        body: ListView.builder(
          itemCount: schemes.length,
          itemBuilder: (context, index) {
            final scheme = schemes[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheme.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _speakSchemeDetails(
                                "${scheme.name}. ${scheme.description}. Benefits: ${scheme.benefits}",
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                _isSpeaking
                                    ? Icons.stop_circle
                                    : Icons.volume_up,
                                color: Colors.green[700],
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scheme.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${strings['benefits'] ?? 'Benefits'}: ${scheme.benefits}",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(scheme.fullInfo, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          child: Text(
                            strings['visit_website'] ??
                                'Visit Official Website',
                          ),
                          onPressed: () async {
                            final uri = Uri.parse(scheme.website);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(scheme.website);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: SelectableText(
                            scheme.website,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SchemeDetailPage extends StatelessWidget {
  final int schemeIndex;
  final String languageCode;
  const SchemeDetailPage({
    super.key,
    required this.schemeIndex,
    required this.languageCode,
  });

  Future<void> _launchWebsite(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch website')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final schemes = localizedSchemes[languageCode] ?? localizedSchemes['en']!;
    final scheme = schemes[schemeIndex];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 78, 239, 9), Color(0xFFa8e063)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(scheme.name),
          backgroundColor: Colors.green.withOpacity(0.8),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheme.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(scheme.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Text(
                '${languageCode == 'hi'
                    ? 'लाभ'
                    : languageCode == 'kn'
                    ? 'ಪ್ರಯೋಜನೆಗಳು'
                    : 'Benefits'}: ${scheme.benefits}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(scheme.fullInfo, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    child: Text(
                      languageCode == 'hi'
                          ? 'आधिकारिक वेबसाइट देखें'
                          : languageCode == 'kn'
                          ? 'ಅಧಿಕೃತ ವೆಬ್‌ಸೈಟ್ ನೋಡಿ'
                          : 'Visit Official Website',
                    ),
                    onPressed: () => _launchWebsite(scheme.website, context),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _launchWebsite(scheme.website, context),
                    child: SelectableText(
                      scheme.website,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Scheme {
  final String name;
  final String description;
  final String benefits;
  final String fullInfo;
  final String website;

  Scheme({
    required this.name,
    required this.description,
    required this.benefits,
    required this.fullInfo,
    required this.website,
  });
}

final Map<String, List<Scheme>> localizedSchemes = {
  'te': [
    Scheme(
      name: "జాతీయ స్థిరమైన వ్యవసాయ మిషన్ (NMSA)",
      description:
          "వాతావరణ మార్పు అనుకూలత చర్యలు, నీటి వినియోగ సామర్థ్యం, నేల ఆరోగ్య నిర్వహణ మరియు వనరుల సంరక్షణ ద్వారా స్థిరమైన వ్యవసాయాన్ని ప్రోత్సహిస్తుంది. వర్షాధార ప్రాంత అభివృద్ధి మరియు వాతావరణ మార్పు అనుకూలత పై దృష్టి కేంద్రీకరించబడింది.",
      benefits:
          "వాతావరణ-స్థితిస్థాపక వ్యవసాయం మరియు స్థిరమైన పద్ధతులకు మద్దతు.",
      fullInfo:
          "NMSA ముఖ్యంగా వర్షాధార ప్రాంతాల్లో సమగ్ర వ్యవసాయం, నీటి వినియోగ సామర్థ్యం, నేల ఆరోగ్య నిర్వహణ మరియు వనరుల సంరక్షణపై దృష్టి సారించి వ్యవసాయ ఉత్పాదకతను పెంచడం లక్ష్యంగా పెట్టుకుంది.",
      website: "https://nmsa.dac.gov.in/",
    ),
    Scheme(
      name: "గ్రామీణ భండారణ యోజన",
      description:
          "రైతులకు వ్యవసాయ ఉత్పత్తులు, ప్రాసెస్ చేసిన వ్యవసాయ ఉత్పత్తులు మరియు వ్యవసాయ ఇన్‌పుట్‌లను నిల్వ చేయడానికి సహాయపడే గ్రామీణ ప్రాంతాల్లో సైంటిఫిక్ నిల్వ సామర్థ్యాన్ని సృష్టించడం. గ్రేడింగ్, ప్రమాణీకరణ మరియు నాణ్యతా నియంత్రణను ప్రోత్సహిస్తుంది.",
      benefits: "నిల్వ మౌలిక సదుపాయాలు మరియు నాణ్యత నిర్వహణ మద్దతు.",
      fullInfo:
          "వ్యవసాయ-స్థాయి నిల్వ సామర్థ్యాన్ని సృష్టించడం ద్వారా మరియు పంట కోత తర్వాత రుణాలకు మద్దతు ఇవ్వడం ద్వారా ఒత్తిడి అమ్మకాలను నివారించడం లక్ష్యంగా పెట్టుకుంది.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "సమగ్ర వ్యవసాయ మార్కెటింగ్ పథకం (ISAM)",
      description:
          "మార్కెటింగ్ మౌలిక సదుపాయాలను బలోపేతం చేయడం, వినూత్న మార్కెటింగ్ పరిష్కారాలు మరియు వ్యవసాయ మార్కెట్ సమాచార నెట్‌వర్క్ ద్వారా రైతులను మార్కెట్లతో సమన్వయం చేయడాన్ని ప్రోత్సహిస్తుంది.",
      benefits: "మార్కెట్ మౌలిక సదుపాయాల అభివృద్ధి మరియు సమాచార సేవలు.",
      fullInfo:
          "ISAM ఆధునిక మౌలిక సదుపాయాలు మరియు సమాచార వ్యాప్తి ద్వారా రైతులను మార్కెట్లతో అనుసంధానిస్తుంది.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "జాతీయ సేంద్రియ వ్యవసాయ ప్రాజెక్టు (NPOF)",
      description:
          "సేంద్రియ వ్యవసాయ పద్ధతులు, ధ్రువీకరణ ప్రక్రియలు మరియు సేంద్రియ ఇన్‌పుట్‌ల ఉత్పత్తిని ప్రోత్సహిస్తుంది. సాంకేతిక సామర్థ్య నిర్మాణాన్ని అందిస్తుంది మరియు సేంద్రియ ఇన్‌పుట్ ఉత్పత్తి యూనిట్లకు మద్దతు ఇస్తుంది.",
      benefits: "శిక్షణ, ధ్రువీకరణ మద్దతు మరియు సేంద్రియ ఇన్‌పుట్ సహాయం.",
      fullInfo:
          "NPOF సేంద్రియ వ్యవసాయ పద్ధతులను ప్రోత్సహిస్తుంది మరియు సేంద్రియ వ్యవసాయంలోకి మారేందుకు రైతులకు మద్దతు ఇస్తుంది.",
      website: "https://pgsindia-ncof.gov.in/",
    ),
    Scheme(
      name: "పశుసంపద బీమా పథకం",
      description:
          "రైతులు మరియు పశుపోషకులకు వారి జంతువుల మరణం లేదా శాశ్వత అంగవైకల్యం వల్ల కలిగే నష్టానికి బీమా కవరేజీని అందిస్తుంది. బీమాను అందుబాటులో ఉంచడానికి ప్రీమియం చెల్లింపును సబ్సిడీ చేస్తుంది.",
      benefits: "సబ్సిడీ ప్రీమియంతో పశుసంపద బీమా కవరేజీ.",
      fullInfo:
          "బీమా మద్దతు ద్వారా ఉత్పాదక పశుసంపద మరణం వల్ల కలిగే నష్టాల నుండి రైతులను రక్షిస్తుంది.",
      website: "https://dahd.nic.in/",
    ),
    Scheme(
      name: "వ్యవసాయ విస్తరణ & సాంకేతికత పై జాతీయ మిషన్ (NMAET)",
      description:
          "సాంకేతిక వ్యాప్తి ద్వారా రైతులకు మద్దతు ఇవ్వడానికి విస్తరణ యంత్రాంగాన్ని బలోపేతం చేస్తుంది. వ్యవసాయ యాంత్రీకరణ, స్థిరమైన వ్యవసాయం మరియు మొక్కల రక్షణపై దృష్టి సారిస్తుంది.",
      benefits: "సాంకేతిక ప్రాప్యత, శిక్షణ మరియు విస్తరణ సేవలు.",
      fullInfo:
          "NMAET మెరుగైన విస్తరణ సేవలు మరియు సామర్థ్య నిర్మాణం ద్వారా రైతులకు సాంకేతిక జ్ఞానం చేరువను నిర్ధారిస్తుంది.",
      website: "https://extensionreforms.dacnet.nic.in/",
    ),
    Scheme(
      name: "ప్రధాన మంత్రి గ్రామ సించాయి యోజన (PMGSY)",
      description:
          "పొలాలలో నీటి భౌతిక ప్రాప్యతను పెంచుతుంది మరియు నిశ్చిత నీటిపారుదల కింద సాగు చేయగల ప్రాంతాన్ని విస్తరిస్తుంది. సమర్థవంతమైన నీటి నిర్వహణ పద్ధతులు మరియు సూక్ష్మ నీటిపారుదలను ప్రోత్సహిస్తుంది.",
      benefits: "నీటిపారుదల మౌలిక సదుపాయాలు మరియు నీటి నిర్వహణ మద్దతు.",
      fullInfo:
          "PMGSY వ్యవసాయంలో నీటిపారుదల ప్రాప్యత మరియు నీటి వినియోగ సామర్థ్యాన్ని మెరుగుపరచడంపై దృష్టి సారిస్తుంది.",
      website: "https://pmgsy.nic.in/",
    ),
    Scheme(
      name: "జాతీయ వ్యవసాయ బీమా పథకం (NAIS)",
      description:
          "ప్రకృతి విపత్తులు, పురుగులు మరియు వ్యాధుల కారణంగా పంట విఫలమైన సందర్భంలో రైతులకు ఆర్థిక సహాయం అందిస్తుంది. ప్రత్యేకించి విపత్తు సంవత్సరాల్లో వ్యవసాయ ఆదాయాన్ని స్థిరీకరిస్తుంది.",
      benefits: "పంట బీమా కవరేజీ మరియు విపత్తు పరిహారం.",
      fullInfo:
          "NAIS పంట నష్టాల నుండి రైతులను రక్షిస్తూ ఆదాయాన్ని స్థిరీకరించడానికి మరియు క్రెడిట్ అర్హతను నిర్ధారించడానికి సహాయపడుతుంది.",
      website: "https://pmfby.gov.in/",
    ),
    Scheme(
      name: "ప్రధాన మంత్రి కిసాన్ మాన్‌ధన్ యోజన",
      description:
          "చిన్న మరియు సన్నకారు రైతులకు 60 సంవత్సరాల వయస్సు తర్వాత నెలవారీ పెన్షన్ అందించడానికి రూపొందించబడిన పెన్షన్ పథకం. 18 నుండి 40 సంవత్సరాల వయస్సు గల రైతులు నమోదు చేసుకోవడానికి అర్హులు.",
      benefits: "60 సంవత్సరాల వయస్సు తర్వాత నెలవారీ పెన్షన్.",
      fullInfo:
          "PMKMY 60 సంవత్సరాల వయస్సు తర్వాత చిన్న మరియు సన్నకారు రైతులకు నెలకు రూ. 3,000 పెన్షన్ అందిస్తుంది.",
      website: "https://www.pmkmy.gov.in/",
    ),
    Scheme(
      name: "ప్రధానమంత్రి కిసాన్ స‌మ్మాన్ నిధి (PM‑KISAN)",
      description:
          "ఈ పథకం కింద, 2 హెక్టార్ల లోపు సాగు భూమి ఉన్న రైతు కుటుంబాలకు సంవత్సరానికి ₹6,000 ఆర్థిక సహాయం అందిస్తుంది. ఈ మొత్తాన్ని మూడు సమాన వాయిదాలలో నేరుగా వారి బ్యాంకు ఖాతాలో జమ చేస్తారు. ఇది చిన్న మరియు సన్నకారు రైతులకు వర్తిస్తుంది.",
      benefits: "₹2,000 × 3 విడతలుగా DBT ద్వారా నెలకొల్పి ₹6,000.",
      fullInfo:
          "PM‑KISAN చిన్న మరియు అంచురేల రైతులకు సంవత్సరానికి ₹6,000 నేరుగా బ్యాంక్ ఖాతాలో అందిస్తుంది.",
      website: "https://pmkisan.gov.in",
    ),
    Scheme(
      name: "ప్రధాన్ మంత్రి పంటల బీమా పథకం (PMFBY)",
      description:
          "ప్రకృతి వైపరీత్యాలు, తెగుళ్లు మరియు వ్యాధుల వలన పంట నష్టపోయినప్పుడు రైతులకు ఆర్థిక సహాయం అందించే బీమా పథకం. నోటిఫై చేసిన పంటలను పండించే రైతులందరూ, కౌలు రైతులతో సహా, ఈ పథకానికి అర్హులు.",
      benefits: "ప్రీమియం సబ్సిడీ, పంట నష్టానికి పరిహారం.",
      fullInfo:
          "PMFBY ప్రకృతి విపత్తులు, పంట కీటకాలు మరియు వ్యాధుల నుండి రక్షణ.",
      website: "https://pmfby.gov.in",
    ),
    Scheme(
      name: "కిసాన్ క్రెడిట్ కార్డ్ (KCC)",
      description:
          "రైతులకు వారి వ్యవసాయ మరియు ఇతర అనుబంధ కార్యకలాపాల కోసం తక్కువ వడ్డీకి రుణాలు అందించే పథకం. రైతులు, పశుపోషకులు మరియు మత్స్యకారులు అందరూ ఈ పథకం కింద రుణాలకు అర్హులు.",
      benefits: "తక్కువ వడ్డీ, ఇతర ఆర్థిక అవసరాలకు ఉపయోగపడే క్రెడిట్.",
      fullInfo: "KCC తక్షణ వ్యవసాయ అవసరాల కోసం తక్కువ వడ్డీ రుణం అందిస్తుంది.",
      website: "https://pmfby.gov.in/kcc",
    ),
    Scheme(
      name: "PM‑KUSUM",
      description:
          "గ్రామీణ ప్రాంతాల్లో సౌరశక్తి పంపులను ఏర్పాటు చేయడానికి మరియు గ్రిడ్‌కు అనుసంధానించబడిన సౌర విద్యుత్ ప్లాంట్లను ప్రోత్సహించడానికి ఈ పథకం ఉద్దేశించబడింది. విద్యుత్ కనెక్షన్ లేని లేదా అస్థిర విద్యుత్ సరఫరా ఉన్న రైతులు అర్హులు.",
      benefits:
          "విద్యుత్ బిల్లులు తగ్గుతాయి, అధిక విద్యుత్ విక్రయంతో అదనపు ఆదాయం.",
      fullInfo:
          "PM‑KUSUM గ్రామీణ ప్రాంతాల్లో సౌర విద్యుత్తు పంపులు మరియు గ్రిడ్ లోకి వెళ్తున్న సౌర విద్యుత్తును ప్రోత్సహించే పథకం.",
      website: "https://mnre.gov.in/pm-kusum",
    ),
    Scheme(
      name: "e‑NAM (జాతీయ వ్యవసాయ మార్కెట్)",
      description:
          "రైతులు తమ ఉత్పత్తులను ఆన్‌లైన్‌లో విక్రయించడానికి ఒక డిజిటల్ వేదిక. ఇది పారదర్శకమైన ధరలను మరియు మధ్యవర్తుల ప్రమేయాన్ని తగ్గిస్తుంది. నమోదు చేసుకున్న రైతులు మరియు వ్యాపారులు దీనికి అర్హులు.",
      benefits: "సరైన ధర, మధ్యవర్తులు తగ్గడం, పారదర్శక వ్యాపారం.",
      fullInfo:
          "e‑NAM రైతులు తమ వ్యవసాయ ఉత్పత్తులను ఆన్‌లైన్‌లో విక్రయించడానికి డిజిటల్ వేదిక.",
      website: "https://enam.gov.in",
    ),
    Scheme(
      name: "మట్టి ఆరోగ్య కార్డు పథకం",
      description:
          "రైతులందరికీ వారి పొలంలోని మట్టి ఆరోగ్య పరిస్థితిని తెలియజేయడానికి మరియు పోషకాల యాజమాన్యంపై సూచనలు అందించడానికి ఈ పథకం సహాయపడుతుంది. రైతులందరూ ఈ పథకానికి అర్హులు.",
      benefits: "మట్టి ప్రమాణాలు, సరైన పెరుగుదలకు అవసరమైన కూరగాయాలు.",
      fullInfo:
          "మట్టివారుతెచ్చి ఆరోగ్య కార్డు పథకం మట్టి రసం నమూనాలు పరీక్షించి పోషక సూచనలు అందిస్తుంది.",
      website: "https://soilhealth.dac.gov.in",
    ),
    Scheme(
      name: "RKVY‑RAFTAAR",
      description:
          "వ్యవసాయం మరియు అనుబంధ రంగాలలో మౌలిక సదుపాయాలను బలోపేతం చేయడానికి మరియు ఆవిష్కరణలను ప్రోత్సహించడానికి రాష్ట్రాలకు ఆర్థిక సహాయం అందిస్తుంది. రాష్ట్ర ప్రభుత్వాలు మరియు రైతులు అర్హులు.",
      benefits: "ప్రాజెక్ట్ త్రుటి పంపిణీ, శిక్షణ, సాంకేతిక సహాయం.",
      fullInfo:
          "RKVY‑RAFTAAR వ్యవసాయ మౌలికసౌకర్యం మరియు అగ్రి‑స్టార్టప్‌లకు ప్రోత్సాహకాలు.",
      website: "https://rkvy.nic.in",
    ),
    Scheme(
      name: "NABARD – SC/ST రైతులకు ప్రత్యేక పథకాలు",
      description:
          "SC/ST వర్గాలకు చెందిన రైతులకు వ్యవసాయం మరియు గ్రామీణాభివృద్ధి కార్యకలాపాల కోసం ఆర్థిక సహాయం మరియు శిక్షణను అందించే ప్రత్యేక పథకాలు. SC/ST రైతులు మరియు వారి సంస్థలు అర్హులు.",
      benefits: "సబ్సిడీలు, శిక్షణలు, మౌలిక నిర్మాణం అభివృద్ధి.",
      fullInfo: "NABARD SC/ST రైతు కుటుంబాలకు ప్రత్యేక సహాయం అందిస్తుంది.",
      website: "https://www.nabard.org",
    ),
    Scheme(
      name: "జాతీయ హార్టికల్చర్ మిషన్ (NHM)",
      description:
          "ఉద్యానవన పంటల ఉత్పత్తి మరియు ఉత్పాదకతను పెంచడానికి, అలాగే నాణ్యతను మెరుగుపరచడానికి మరియు మార్కెటింగ్‌ను సులభతరం చేయడానికి ఈ పథకం సహాయపడుతుంది. ఉద్యానవన రైతులు మరియు ఉత్పత్తిదారుల సంఘాలు అర్హులు.",
      benefits: "మద్దతు బడ్జెట్, శిక్షణా తరగతులు, మార్కెటింగ్ కనెక్షన్.",
      fullInfo:
          "NHM పండ్లు, పూలు, మసాలా ఉత్పత్తులను అభివృద్ధి చేయటానికి ప్రోత్సాహించిబ తీయబడ్డ ప్రోగ్రామ్.",
      website: "https://www.nhm.gov.in",
    ),
    Scheme(
      name: "మహాత్మా గాంధీ జాతీయ గ్రామీణ ఉపాధి హామీ పథకం (MGNREGS)",
      description:
          "గ్రామీణ కుటుంబాలకు సంవత్సరానికి 100 రోజుల వేతన ఉపాధిని హామీ ఇచ్చే చట్టబద్ధమైన పథకం. గ్రామీణ ప్రాంతాల్లో నివసించే ఏ వయోజనుడైనా దీనికి అర్హుడు.",
      benefits: "గ్యారెంటీదారు పనికి పని – సమ్మానార్థక వేతనం.",
      fullInfo:
          "MGNREGS గ్రామీణ వయస్సునుంచి వారికి వార్షికంగా 100 రోజుల పని హామీ అందిస్తుంది.",
      website: "https://nrega.nic.in",
    ),
  ],
  'ta': [
    Scheme(
      name: "தேசிய நிலைத்த வேளாண்மை திட்டம் (NMSA)",
      description:
          "காலநிலை மாற்ற தகவமைப்பு நடவடிக்கைகள், நீர் பயன்பாட்டு திறன், மண் ஆரோக்கிய மேலாண்மை மற்றும் வள பாதுகாப்பு மூலம் நிலையான வேளாண்மையை ஊக்குவிக்கிறது. மழை நீர் பாசன பகுதி மேம்பாடு மற்றும் காலநிலை மாற்ற தகவமைப்பு மீது கவனம் செலுத்துகிறது.",
      benefits:
          "காலநிலை-தாக்குப்பிடிக்கும் வேளாண்மை மற்றும் நிலையான நடைமுறைகளுக்கான ஆதரவு.",
      fullInfo:
          "NMSA குறிப்பாக மழை நீர் பாசன பகுதிகளில் ஒருங்கிணைந்த விவசாயம், நீர் பயன்பாட்டு திறன், மண் ஆரோக்கிய மேலாண்மை மற்றும் வள பாதுகாப்பு மீது கவனம் செலுத்தி வேளாண் உற்பத்தித்திறனை மேம்படுத்த இலக்கு கொண்டுள்ளது.",
      website: "https://nmsa.dac.gov.in/",
    ),
    Scheme(
      name: "கிராமீன் பண்டாரன் யோஜனா",
      description:
          "விவசாயிகள் வேளாண் விளைபொருட்கள், பதப்படுத்தப்பட்ட வேளாண் விளைபொருட்கள் மற்றும் வேளாண் உள்ளீடுகளை சேமிக்க உதவும் வகையில் கிராமப்புற பகுதிகளில் அறிவியல் சேமிப்பு திறனை உருவாக்குதல். தரப்படுத்துதல், தரநிர்ணயம் மற்றும் தர கட்டுப்பாட்டை ஊக்குவிக்கிறது.",
      benefits: "சேமிப்பு உள்கட்டமைப்பு மற்றும் தர பராமரிப்பு ஆதரவு.",
      fullInfo:
          "பண்ணை-நிலை சேமிப்பு திறனை உருவாக்குவதன் மூலமும் அறுவடைக்குப் பிந்தைய கடன்களுக்கு ஆதரவளிப்பதன் மூலமும் நெருக்கடி விற்பனையைத் தடுப்பதை நோக்கமாகக் கொண்டுள்ளது.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "ஒருங்கிணைந்த வேளாண் சந்தைப்படுத்தல் திட்டம் (ISAM)",
      description:
          "சந்தைப்படுத்தல் உள்கட்டமைப்பை வலுப்படுத்துதல், புதுமையான சந்தைப்படுத்தல் தீர்வுகள் மற்றும் வேளாண் சந்தை தகவல் வலையமைப்பு மூலம் விவசாயிகளை சந்தைகளுடன் ஒருங்கிணைப்பதை ஊக்குவிக்கிறது.",
      benefits: "சந்தை உள்கட்டமைப்பு மேம்பாடு மற்றும் தகவல் சேவைகள்.",
      fullInfo:
          "ISAM நவீன உள்கட்டமைப்பு மற்றும் தகவல் பரவல் மூலம் விவசாயிகளை சந்தைகளுடன் ஒருங்கிணைக்கிறது.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "இயற்கை வேளாண்மைக்கான தேசிய திட்டம் (NPOF)",
      description:
          "இயற்கை வேளாண் நடைமுறைகள், சான்றளிப்பு செயல்முறைகள் மற்றும் இயற்கை உள்ளீடுகளின் உற்பத்தியை ஊக்குவிக்கிறது. தொழில்நுட்ப திறன் மேம்பாட்டை வழங்குகிறது மற்றும் இயற்கை உள்ளீடு உற்பத்தி அலகுகளுக்கு ஆதரவளிக்கிறது.",
      benefits: "பயிற்சி, சான்றளிப்பு ஆதரவு மற்றும் இயற்கை உள்ளீடு உதவி.",
      fullInfo:
          "NPOF இயற்கை வேளாண் முறைகளை ஊக்குவிக்கிறது மற்றும் இயற்கை வேளாண்மைக்கு மாறும் விவசாயிகளுக்கு ஆதரவளிக்கிறது.",
      website: "https://pgsindia-ncof.gov.in/",
    ),
    Scheme(
      name: "கால்நடை காப்பீட்டு திட்டம்",
      description:
          "விவசாயிகள் மற்றும் கால்நடை வளர்ப்போருக்கு அவர்களது விலங்குகளின் இறப்பு அல்லது நிரந்தர ஊனம் காரணமாக ஏற்படும் இழப்புக்கு காப்பீட்டு பாதுகாப்பை வழங்குகிறது. காப்பீட்டை அணுகக்கூடியதாக்க பிரீமியம் கட்டணத்திற்கு மானியம் வழங்குகிறது.",
      benefits:
          "மானியம் அளிக்கப்பட்ட பிரீமியங்களுடன் கால்நடைகளுக்கான காப்பீட்டு பாதுகாப்பு.",
      fullInfo:
          "காப்பீட்டு ஆதரவின் மூலம் உற்பத்தி கால்நடைகளின் இறப்பால் ஏற்படும் இழப்புகளில் இருந்து விவசாயிகளைப் பாதுகாக்கிறது.",
      website: "https://dahd.nic.in/",
    ),
    Scheme(
      name: "வேளாண் விரிவாக்கம் & தொழில்நுட்பத்திற்கான தேசிய திட்டம் (NMAET)",
      description:
          "தொழில்நுட்ப பரவல் மூலம் விவசாயிகளுக்கு ஆதரவளிக்க விரிவாக்க அமைப்பை வலுப்படுத்துகிறது. வேளாண் இயந்திரமயமாக்கல், நிலையான வேளாண்மை மற்றும் தாவர பாதுகாப்பில் கவனம் செலுத்துகிறது.",
      benefits: "தொழில்நுட்ப அணுகல், பயிற்சி மற்றும் விரிவாக்க சேவைகள்.",
      fullInfo:
          "NMAET சிறந்த விரிவாக்க சேவைகள் மற்றும் திறன் மேம்பாடு மூலம் விவசாயிகளுக்கு தொழில்நுட்ப அணுகலை உறுதி செய்கிறது.",
      website: "https://extensionreforms.dacnet.nic.in/",
    ),
    Scheme(
      name: "பிரதமர் கிராம சிஞ்சாய் யோஜனா (PMGSY)",
      description:
          "பண்ணைகளில் நீரின் உடல் அணுகலை மேம்படுத்துகிறது மற்றும் உறுதியான பாசனத்தின் கீழ் சாகுபடி பகுதியை விரிவுபடுத்துகிறது. திறமையான நீர் மேலாண்மை நடைமுறைகள் மற்றும் நுண்ணீர் பாசனத்தை ஊக்குவிக்கிறது.",
      benefits: "பாசன உள்கட்டமைப்பு மற்றும் நீர் மேலாண்மை ஆதரவு.",
      fullInfo:
          "PMGSY வேளாண்மையில் பாசன அணுகல் மற்றும் நீர் பயன்பாட்டு திறனை மேம்படுத்துவதில் கவனம் செலுத்துகிறது.",
      website: "https://pmgsy.nic.in/",
    ),
    Scheme(
      name: "தேசிய வேளாண் காப்பீட்டு திட்டம் (NAIS)",
      description:
          "இயற்கை பேரழிவுகள், பூச்சிகள் மற்றும் நோய்களால் பயிர் இழப்பு ஏற்படும் நிலையில் விவசாயிகளுக்கு நிதி உதவி வழங்குகிறது. குறிப்பாக பேரழிவு ஆண்டுகளில் பண்ணை வருமானத்தை நிலைப்படுத்துகிறது.",
      benefits: "பயிர் காப்பீட்டு பாதுகாப்பு மற்றும் பேரழிவு இழப்பீடு.",
      fullInfo:
          "NAIS பயிர் இழப்புகளில் இருந்து விவசாயிகளைப் பாதுகாத்து வருமானத்தை நிலைப்படுத்த மற்றும் கடன் தகுதியை உறுதி செய்ய உதவுகிறது.",
      website: "https://pmfby.gov.in/",
    ),
    Scheme(
      name: "பிரதமர் கிசான் மான்தன் யோஜனா",
      description:
          "சிறு மற்றும் குறு விவசாயிகளுக்கு 60 வயதிற்குப் பிறகு மாதாந்திர ஓய்வூதியம் வழங்க வடிவமைக்கப்பட்ட ஓய்வூதியத் திட்டம். 18 முதல் 40 வயது வரையிலான விவசாயிகள் பதிவு செய்ய தகுதியானவர்கள்.",
      benefits: "60 வயதிற்குப் பிறகு மாதாந்திர ஓய்வூதியம்.",
      fullInfo:
          "PMKMY 60 வயதிற்குப் பிறகு சிறு மற்றும் குறு விவசாயிகளுக்கு மாதம் ரூ.3,000 ஓய்வூதியம் வழங்குகிறது.",
      website: "https://www.pmkmy.gov.in/",
    ),
    Scheme(
      name: "பிரதமர் கிசான் சம்மான நிதி (PM‑KISAN)",
      description:
          "சிறு மற்றும் குறு விவசாயிகளுக்கு ஆண்டுக்கு ₹6,000 நிதி உதவி வழங்கும் திட்டம். இந்த தொகை மூன்று சம தவணைகளாக நேரடியாக அவர்களின் வங்கி கணக்கில் செலுத்தப்படுகிறது. 2 ஹெக்டேர் வரை விவசாய நிலம் உள்ள அனைத்து விவசாயிகளும் தகுதியுடையவர்கள்.",
      benefits: "₹2,000 × 3 தவணைகளாக DBT மூலம் ஆண்டு முழுவதும் ₹6,000.",
      fullInfo:
          "PM‑KISAN சிறு மற்றும் வரம்பு கொண்ட விவசாயிகளுக்கு ஆண்டிற்கு ₹6,000 நேரடி நிதி உதவி வழங்குகிறது.",
      website: "https://pmkisan.gov.in",
    ),
    Scheme(
      name: "பிரதமர் பயிர் காப்பீட்டு திட்டம் (PMFBY)",
      description:
          "இயற்கை பேரழிவுகள், பூச்சி தாக்குதல்கள் மற்றும் நோய்களால் ஏற்படும் பயிர் இழப்புகளுக்கு விவசாயிகளுக்கு காப்பீடு வழங்கும் திட்டம். அறிவிக்கப்பட்ட பயிர்களை பயிரிடும் அனைத்து விவசாயிகளும், குத்தகைதாரர்கள் உட்பட, இத்திட்டத்திற்கு தகுதியானவர்கள்.",
      benefits: "பயிர் நஷ்டத்திற்கு நஷ்டப்பண விபரீத மற்றும் அரசு சலுகைகள்.",
      fullInfo:
          "PMFBY இயற்கை பேரழிவுகள், பூச்சி மற்றும் நோய்கள் போன்றவற்றிடமிருந்து பயிர்களை காப்பீடு செய்கிறது.",
      website: "https://pmfby.gov.in",
    ),
    Scheme(
      name: "கிசான் கடன் அட்டை (KCC)",
      description:
          "விவசாயிகளின் குறுகிய கால கடன் தேவைகளை பூர்த்தி செய்வதற்காக குறைந்த வட்டியில் கடன் வழங்கும் திட்டம். விவசாயிகள், கால்நடை வளர்ப்போர் மற்றும் மீனவர்கள் உட்பட அனைவரும் இந்த திட்டத்தின் கீழ் கடன் பெற தகுதியுடையவர்கள்.",
      benefits:
          "குறைந்த வட்டி, பயிர் விதைகள், கழிப்பு, விற்பனை என்ற செயல்களுக்கு உதவிகரமாக இருக்கும் நிதி.",
      fullInfo:
          "KCC விவசாயிகளுக்கு வசதியான வட்டி விகிதத்தில் தொழில்நுட்ப ஆதரவு கடன் வழங்குகிறது.",
      website: "https://pmfby.gov.in/kcc",
    ),
    Scheme(
      name: "PM‑KUSUM",
      description:
          "கிராமப்புறங்களில் சோலார் பம்புகளை நிறுவுவதற்கும், கிரிட்-இணைக்கப்பட்ட சோலார் மின் நிலையங்களை ஊக்குவிப்பதற்கும் இந்தத் திட்டம் உதவுகிறது. மின்சார இணைப்பு இல்லாத அல்லது நிலையற்ற மின்சாரம் உள்ள விவசாயிகள் தகுதியுடையவர்கள்.",
      benefits: "மின் செலவு குறைப்பு, அதிகமின்சாரத்தை விற்று வருமானம்.",
      fullInfo:
          "PM‑KUSUM கிராமப்புறங்களில் சோலார் நீர் பம்புகளை நிறுவுவதற்கும் கிரிட் இணைக்கப்பட்ட சோலார் சக்தியை ஊக்குவிப்பதற்கும் செயல்.",
      website: "https://mnre.gov.in/pm-kusum",
    ),
    Scheme(
      name: "e‑NAM (தேசிய வேளாண் சந்தை)",
      description:
          "விவசாயிகள் தங்கள் விளைபொருட்களை ஆன்லைனில் விற்க ஒரு டிஜிட்டல் தளத்தை வழங்குகிறது, இது வெளிப்படையான விலையையும் இடைத்தரகர்களின் தேவையையும் குறைக்கிறது. பதிவுசெய்த விவசாயிகள் மற்றும் வர்த்தகர்கள் இதற்கு தகுதியுடையவர்கள்.",
      benefits: "வெளிப்படையான விலைப்பெறுதல், இடைநிலைவர்கள் குறைவு.",
      fullInfo:
          "e‑NAM விவசாய உற்பத்தியை ஆன்லைனில் விற்பனை செய்யும் டிஜிட்டல் சந்தை.",
      website: "https://enam.gov.in",
    ),
    Scheme(
      name: "மண் ஆரோக்கிய அட்டை திட்டம்",
      description:
          "அனைத்து விவசாயிகளுக்கும் அவர்களின் வயலின் மண் ஆரோக்கியம் குறித்து తెలియజేయడానికి மற்றும் உர மேலாண்மை குறித்த பரிந்துரைகளை வழங்குகிறது. அனைத்து விவசாயிகளும் இத்திட்டத்திற்கு தகுதியுடையவர்கள்.",
      benefits: "தனிப்பயன் உர பரிந்துரைகள் மற்றும் பயிர் தேர்வு உதவி.",
      fullInfo:
          "மண் ஆரோக்கியச்சீட்டு திட்டம் மண் பரிசோதனை மற்றும் உரம் மேலாண்மை பரிந்துரை வழங்குகிறது.",
      website: "https://soilhealth.dac.gov.in",
    ),
    Scheme(
      name: "RKVY‑RAFTAAR",
      description:
          "வேளாண்மை மற்றும் அதனுடன் தொடர்புடைய துறைகளில் உள்கட்டமைப்பை வலுப்படுத்தவும், புதுமைகளை ஊக்குவிக்கவும் மாநிலங்களுக்கு நிதி உதவி அளிக்கிறது. மாநில அரசுகள் மற்றும் விவசாயிகள் தகுதியானவர்கள்.",
      benefits: "திட்ட நிதி, தொழில்நுட்ப மாகாணம், பயிற்சி.",
      fullInfo:
          "RKVY‑RAFTAAR வேளாண் மேம்பாடு, தந்திரன் மற்றும் தொழில்நுட்பங்களை ஊக்குவிக்கும் திட்டம்.",
      website: "https://rkvy.nic.in",
    ),
    Scheme(
      name: "NABARD – SC/ST விவசாயிகள் ஏற்கனவே திட்டங்கள்",
      description:
          "SC/ST சமூகங்களைச் சேர்ந்த விவசாயிகளுக்கு விவசாயம் மற்றும் ஊரக மேம்பாட்டு நடவடிக்கைகளுக்கு நிதி உதவி மற்றும் பயிற்சி அளிக்கும் சிறப்புத் திட்டங்கள். SC/ST விவசாயிகள் மற்றும் அவர்களது நிறுவனங்கள் தகுதியானவர்கள்.",
      benefits: "சலுகைகள், பயிற்சி மற்றும் கட்டமைப்பு மேம்பாடு.",
      fullInfo:
          "NABARD SC/ST விவசாயிக் குடும்பங்களுக்கு தீர்மான உதவி வழங்குகிறது.",
      website: "https://www.nabard.org",
    ),
    Scheme(
      name: "தேசிய தோட்டக்கலை திட்டம் (NHM)",
      description:
          "தோட்டக்கலைப் பயிர்களின் உற்பத்தி மற்றும் உற்பத்தித்திறனை அதிகரிக்கவும், தரத்தை மேம்படுத்தவும், சந்தைப்படுத்தலை எளிதாக்கவும் இந்தத் திட்டம் உதவுகிறது. தோட்டக்கலை விவசாயிகள் மற்றும் உற்பத்தியாளர் நிறுவனங்கள் தகுதியானவர்கள்.",
      benefits: "நிதி உதவி, பயிற்சி, சந்தை இணைப்பு.",
      fullInfo:
          "NHM பழம், மலர் மற்றும் மசாலா போன்ற தோட்டக்கலை வளர்ச்சியைக் ஊக்குவிக்கும் திட்டம்.",
      website: "https://www.nhm.gov.in",
    ),
    Scheme(
      name: "மகாத்மா காந்தி தேசிய ஊரக வேலை உறுதித் திட்டம் (MGNREGS)",
      description:
          "கிராமப்புற குடும்பங்களுக்கு ஒரு வருடத்திற்கு 100 நாட்கள் ஊதியத்துடன் கூடிய வேலைவாய்ப்பை உறுதி செய்யும் ஒரு சட்டப்பூர்வ திட்டம். கிராமப்புறங்களில் வசிக்கும் எந்தவொரு வயது வந்தவரும் இதற்கு தகுதியானவர்.",
      benefits: "நியாயமான விலைக்கு வேலை, சம்பளம்.",
      fullInfo:
          "MGNREGS ஆவிடயில்லாத விவசாயிகளுக்கு ஆண்டுக்கு 100 நாள் வேலை உத்தரவாதம் வழங்குகிறது.",
      website: "https://nrega.nic.in",
    ),
  ],
  'en': [
    Scheme(
      name: "National Mission for Sustainable Agriculture (NMSA)",
      description:
          "Promotes sustainable agriculture through climate change adaptation measures, water use efficiency, soil health management, and synergizing resource conservation. Focus on rainfed area development and climate change adaptation.",
      benefits:
          "Support for climate-resilient agriculture and sustainable practices.",
      fullInfo:
          "NMSA aims to enhance agricultural productivity especially in rainfed areas focusing on integrated farming, water use efficiency, soil health management and resources conservation.",
      website: "https://nmsa.dac.gov.in/",
    ),
    Scheme(
      name: "Gramin Bhandaran Yojana",
      description:
          "Creation of scientific storage capacity with allied facilities in rural areas to help farmers store farm produce, processed farm produce and agricultural inputs. Promotes grading, standardization and quality control.",
      benefits: "Storage infrastructure and quality maintenance support.",
      fullInfo:
          "Aims to prevent distress sale by creating farm-level storage capacity and supporting post-harvest loans.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "Integrated Scheme for Agricultural Marketing (ISAM)",
      description:
          "Promotes integration of farmers with markets by strengthening marketing infrastructure, innovative marketing solutions, and agriculture market information network.",
      benefits: "Market infrastructure development and information services.",
      fullInfo:
          "ISAM integrates farmers with markets through modern infrastructure and information dissemination.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "PM-KISAN",
      description:
          "Provides income support of Rs. 6,000 per year to all landholding farmer families. This amount is transferred directly to their bank accounts in three equal installments. Eligibility extends to all farmers who own cultivable land.",
      benefits: "Rs. 6,000 per year in three installments.",
      fullInfo:
          "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN) provides income support to all landholding farmer families across the country, subject to exclusions.",
      website: "https://pmkisan.gov.in/",
    ),
    Scheme(
      name: "Pradhan Mantri Fasal Bima Yojana",
      description:
          "Offers comprehensive crop insurance to protect against financial losses from natural calamities, pests, and diseases. The scheme is available to all farmers, including sharecroppers and tenant farmers, who are growing notified crops in notified areas.",
      benefits: "Insurance coverage and financial support.",
      fullInfo:
          "PMFBY aims to provide insurance coverage and financial support to farmers in the event of crop failure due to natural calamities, pests, and diseases.",
      website: "https://pmfby.gov.in/",
    ),
    Scheme(
      name: "Kisan Credit Card (KCC) Scheme",
      description:
          "Ensures farmers have access to timely and affordable credit for their agricultural and allied activity needs. All farmers, including those involved in animal husbandry and fisheries, are eligible to apply for the KCC.",
      benefits: "Easy access to credit at low interest rates.",
      fullInfo:
          "KCC scheme provides farmers with credit for crop production, post-harvest expenses, and other agricultural needs.",
      website: "https://www.pmkisan.gov.in/Documents/Kisan_Credit_Card.pdf",
    ),
    Scheme(
      name: "Soil Health Card Scheme",
      description:
          "Promotes soil testing and provides farmers with soil health cards, which carry crop-wise recommendations of nutrients and fertilizers required for the individual farms to help farmers to improve productivity. All farmers are eligible.",
      benefits: "Soil health cards and recommendations.",
      fullInfo:
          "Provides soil health cards to farmers with crop-wise recommendations of nutrients and fertilizers required for their farms.",
      website: "https://soilhealth.dac.gov.in/",
    ),
    Scheme(
      name: "Pradhan Mantri Krishi Sinchai Yojana",
      description:
          "Aims to improve irrigation and water use efficiency to expand the cultivable area under assured irrigation. The scheme is available to farmers and water user associations to enhance farm productivity.",
      benefits: "Irrigation infrastructure and support.",
      fullInfo:
          "PMKSY aims to enhance physical access of water on the farm and expand cultivable area under assured irrigation.",
      website: "https://pmksy.gov.in/",
    ),
    Scheme(
      name: "National Food Security Mission",
      description:
          "Focuses on increasing the production of rice, wheat, pulses, and coarse cereals through area expansion and productivity enhancement. The scheme is targeted at farmers in specified districts.",
      benefits: "Subsidies and technical support.",
      fullInfo:
          "NFSM provides support for increasing production of rice, wheat, pulses, and coarse cereals through area expansion and productivity enhancement.",
      website: "https://nfsm.gov.in/",
    ),
    Scheme(
      name: "Rashtriya Krishi Vikas Yojana",
      description:
          "Promotes holistic development of agriculture and allied sectors by allowing states to choose their own agriculture and allied sector development activities. It is available to state governments and farmers.",
      benefits: "Funding for agricultural projects.",
      fullInfo:
          "RKVY provides funds to states to promote agriculture and allied sectors through various projects and initiatives.",
      website: "https://rkvy.nic.in/",
    ),
    Scheme(
      name: "Paramparagat Krishi Vikas Yojana",
      description:
          "Encourages organic farming through a cluster approach and Participatory Guarantee System (PGS) certification. The scheme supports farmers and farmer groups interested in adopting organic practices.",
      benefits: "Support for organic farming.",
      fullInfo:
          "PKVY encourages farmers to adopt organic farming practices and provides support for certification and marketing.",
      website: "https://pgsindia-ncof.gov.in/PKVY/index.aspx",
    ),
    Scheme(
      name: "e-NAM",
      description:
          "A national agriculture market platform that facilitates transparent online trading of agricultural commodities. It is open to farmers, traders, and buyers for better price discovery.",
      benefits: "Online trading platform.",
      fullInfo:
          "e-NAM is a pan-India electronic trading portal which networks the existing APMC mandis to create a unified national market for agricultural commodities.",
      website: "https://enam.gov.in/",
    ),
    Scheme(
      name: "National Project on Organic Farming (NPOF)",
      description:
          "Promotes organic farming practices, certification processes, and production of organic inputs. Provides technical capacity building and supports organic input production units.",
      benefits:
          "Training, certification support, and organic input assistance.",
      fullInfo:
          "NPOF promotes organic farming methods and supports farmers in transition to organic agriculture.",
      website: "https://pgsindia-ncof.gov.in/",
    ),
    Scheme(
      name: "Livestock Insurance Scheme",
      description:
          "Provides insurance coverage to farmers and cattle rearers against loss of their animals due to death or permanent disability. Subsidizes premium payment to make insurance accessible.",
      benefits: "Insurance coverage for livestock with subsidized premiums.",
      fullInfo:
          "Protects farmers against losses due to death of productive livestock through insurance support.",
      website: "https://dahd.nic.in/",
    ),
    Scheme(
      name: "National Mission on Agricultural Extension & Technology (NMAET)",
      description:
          "Strengthens the extension machinery to support farmers through technology dissemination. Focuses on agricultural mechanization, sustainable agriculture, and plant protection.",
      benefits: "Technology access, training, and extension services.",
      fullInfo:
          "NMAET ensures technology reach to farmers through better extension services and capacity building.",
      website: "https://extensionreforms.dacnet.nic.in/",
    ),
    Scheme(
      name: "Pradhan Mantri Gram Sinchai Yojana (PMGSY)",
      description:
          "Enhances physical access of water on farms and expands cultivable area under assured irrigation. Promotes efficient water management practices and micro-irrigation.",
      benefits: "Irrigation infrastructure and water management support.",
      fullInfo:
          "PMGSY focuses on improving irrigation access and water use efficiency in agriculture.",
      website: "https://pmgsy.nic.in/",
    ),
    Scheme(
      name: "National Agricultural Insurance Scheme (NAIS)",
      description:
          "Provides financial support to farmers in the event of crop failure due to natural calamities, pests, and diseases. Stabilizes farm income particularly in disaster years.",
      benefits: "Crop insurance coverage and disaster compensation.",
      fullInfo:
          "NAIS protects farmers against crop losses helping to stabilize income and ensure credit eligibility.",
      website: "https://pmfby.gov.in/",
    ),
    Scheme(
      name: "Pradhan Mantri Kisan Maandhan Yojana",
      description:
          "A pension scheme designed for small and marginal farmers to provide them with a monthly pension after the age of 60. Farmers between 18 and 40 years of age are eligible to enroll.",
      benefits: "Monthly pension after age 60.",
      fullInfo:
          "PMKMY provides a monthly pension of Rs. 3,000 to small and marginal farmers after the age of 60.",
      website: "https://www.pmkmy.gov.in/",
    ),
  ],
  'hi': [
    Scheme(
      name: "राष्ट्रीय सतत कृषि मिशन (NMSA)",
      description:
          "जलवायु परिवर्तन अनुकूलन उपायों, जल उपयोग दक्षता, मृदा स्वास्थ्य प्रबंधन और संसाधन संरक्षण के माध्यम से सतत कृषि को बढ़ावा देता है। वर्षा सिंचित क्षेत्र विकास और जलवायु परिवर्तन अनुकूलन पर ध्यान केंद्रित है।",
      benefits: "जलवायु-लचीली कृषि और सतत प्रथाओं के लिए समर्थन।",
      fullInfo:
          "NMSA का उद्देश्य विशेष रूप से वर्षा सिंचित क्षेत्रों में एकीकृत खेती, जल उपयोग दक्षता, मृदा स्वास्थ्य प्रबंधन और संसाधन संरक्षण पर ध्यान केंद्रित करते हुए कृषि उत्पादकता बढ़ाना है।",
      website: "https://nmsa.dac.gov.in/",
    ),
    Scheme(
      name: "ग्रामीण भंडारण योजना",
      description:
          "किसानों को कृषि उपज, प्रसंस्कृत कृषि उपज और कृषि आदानों को संग्रहीत करने में मदद करने के लिए ग्रामीण क्षेत्रों में संबद्ध सुविधाओं के साथ वैज्ञानिक भंडारण क्षमता का निर्माण। ग्रेडिंग, मानकीकरण और गुणवत्ता नियंत्रण को बढ़ावा देता है।",
      benefits: "भंडारण बुनियादी ढांचा और गुणवत्ता रखरखाव समर्थन।",
      fullInfo:
          "कृषि स्तर पर भंडारण क्षमता बनाकर और फसल कटाई के बाद के ऋणों का समर्थन करके संकट बिक्री को रोकने का लक्ष्य है।",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "एकीकृत कृषि विपणन योजना (ISAM)",
      description:
          "विपणन बुनियादी ढांचे को मजबूत करने, अभिनव विपणन समाधानों और कृषि बाजार सूचना नेटवर्क के माध्यम से किसानों को बाजारों के साथ एकीकृत करने को बढ़ावा देता है।",
      benefits: "बाजार बुनियादी ढांचा विकास और सूचना सेवाएं।",
      fullInfo:
          "ISAM आधुनिक बुनियादी ढांचे और सूचना प्रसार के माध्यम से किसानों को बाजारों के साथ एकीकृत करता है।",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "राष्ट्रीय जैविक खेती परियोजना (NPOF)",
      description:
          "जैविक खेती प्रथाओं, प्रमाणन प्रक्रियाओं और जैविक इनपुट के उत्पादन को बढ़ावा देता है। तकनीकी क्षमता निर्माण प्रदान करता है और जैविक इनपुट उत्पादन इकाइयों का समर्थन करता है।",
      benefits: "प्रशिक्षण, प्रमाणन समर्थन और जैविक इनपुट सहायता।",
      fullInfo:
          "NPOF जैविक खेती के तरीकों को बढ़ावा देता है और जैविक कृषि में परिवर्तन के लिए किसानों का समर्थन करता है।",
      website: "https://pgsindia-ncof.gov.in/",
    ),
    Scheme(
      name: "पशुधन बीमा योजना",
      description:
          "किसानों और पशुपालकों को उनके पशुओं की मृत्यु या स्थायी विकलांगता के कारण होने वाली हानि के खिलाफ बीमा कवरेज प्रदान करता है। बीमा को सुलभ बनाने के लिए प्रीमियम भुगतान को सब्सिडी देता है।",
      benefits: "सब्सिडी वाले प्रीमियम के साथ पशुधन के लिए बीमा कवरेज।",
      fullInfo:
          "बीमा समर्थन के माध्यम से उत्पादक पशुधन की मृत्यु के कारण होने वाले नुकसान से किसानों की रक्षा करता है।",
      website: "https://dahd.nic.in/",
    ),
    Scheme(
      name: "कृषि विस्तार और प्रौद्योगिकी पर राष्ट्रीय मिशन (NMAET)",
      description:
          "प्रौद्योगिकी प्रसार के माध्यम से किसानों का समर्थन करने के लिए विस्तार तंत्र को मजबूत बनाता है। कृषि यांत्रिकीकरण, सतत कृषि और पौध संरक्षण पर ध्यान केंद्रित करता है।",
      benefits: "प्रौद्योगिकी पहुंच, प्रशिक्षण और विस्तार सेवाएं।",
      fullInfo:
          "NMAET बेहतर विस्तार सेवाओं और क्षमता निर्माण के माध्यम से किसानों तक प्रौद्योगिकी पहुंच सुनिश्चित करता है।",
      website: "https://extensionreforms.dacnet.nic.in/",
    ),
    Scheme(
      name: "प्रधानमंत्री ग्राम सिंचाई योजना (PMGSY)",
      description:
          "खेतों पर पानी की भौतिक पहुंच बढ़ाता है और सुनिश्चित सिंचाई के तहत कृषि योग्य क्षेत्र का विस्तार करता है। कुशल जल प्रबंधन प्रथाओं और सूक्ष्म सिंचाई को बढ़ावा देता है।",
      benefits: "सिंचाई बुनियादी ढांचा और जल प्रबंधन समर्थन।",
      fullInfo:
          "PMGSY कृषि में सिंचाई पहुंच और जल उपयोग दक्षता में सुधार पर ध्यान केंद्रित करता है।",
      website: "https://pmgsy.nic.in/",
    ),
    Scheme(
      name: "राष्ट्रीय कृषि बीमा योजना (NAIS)",
      description:
          "प्राकृतिक आपदाओं, कीटों और बीमारियों के कारण फसल की विफलता की स्थिति में किसानों को वित्तीय सहायता प्रदान करता है। विशेष रूप से आपदा के वर्षों में कृषि आय को स्थिर करता है।",
      benefits: "फसल बीमा कवरेज और आपदा मुआवजा।",
      fullInfo:
          "NAIS फसल के नुकसान से किसानों की रक्षा करता है जो आय को स्थिर करने और क्रेडिट पात्रता सुनिश्चित करने में मदद करता है।",
      website: "https://pmfby.gov.in/",
    ),
    Scheme(
      name: "प्रधानमंत्री किसान मानधन योजना",
      description:
          "छोटे और सीमांत किसानों के लिए डिज़ाइन की गई एक पेंशन योजना जो उन्हें 60 वर्ष की आयु के बाद मासिक पेंशन प्रदान करती है। 18 से 40 वर्ष की आयु के किसान नामांकन के लिए पात्र हैं।",
      benefits: "60 वर्ष की आयु के बाद मासिक पेंशन।",
      fullInfo:
          "PMKMY 60 वर्ष की आयु के बाद छोटे और सीमांत किसानों को 3,000 रुपये की मासिक पेंशन प्रदान करता है।",
      website: "https://www.pmkmy.gov.in/",
    ),
    Scheme(
      name: "प्रधानमंत्री किसान सम्मान निधि (PM‑KISAN)",
      description:
          "यह योजना सभी भूमिधारक किसान परिवारों को प्रति वर्ष ₹6,000 की आय सहायता प्रदान करती है। यह राशि तीन समान किस्तों में सीधे उनके बैंक खातों में स्थानांतरित की जाती है। 2 हेक्टेयर तक कृषि योग्य भूमि वाले सभी किसान पात्र हैं।",
      benefits: "₹2,000 × 3 किस्तों में DBT द्वारा प्रतिवर्ष ₹6,000।",
      fullInfo:
          "प्रधान मंत्री किसान सम्मान निधि (PM‑KISAN) छोटे और सीमांत किसानों को प्रतिवर्ष ₹6,000 सीधे बैंक खाते में प्रदान करती है।",
      website: "https://pmkisan.gov.in",
    ),
    Scheme(
      name: "प्रधानमंत्री फसल बीमा योजना (PMFBY)",
      description:
          "प्राकृतिक आपदाओं, कीटों और बीमारियों के कारण फसल के नुकसान से किसानों को वित्तीय सुरक्षा प्रदान करने के लिए एक बीमा योजना। अधिसूचित फसलों को उगाने वाले सभी किसान, जिनमें बटाईदार भी शामिल हैं, इस योजना के लिए पात्र हैं।",
      benefits: "प्रीमियम सब्सिडी और फसल क्षति की भरपाई।",
      fullInfo:
          "PMFBY प्राकृतिक आपदाओं, कीट और रोगों से फसल का बीमा प्रदान करती है।",
      website: "https://pmfby.gov.in",
    ),
    Scheme(
      name: "किसान क्रेडिट कार्ड (KCC)",
      description:
          "किसानों को उनकी कृषि और संबद्ध गतिविधियों के लिए समय पर और सस्ती दरों पर ऋण उपलब्ध कराने की एक योजना। सभी किसान, पशुपालक और मत्स्य पालक इस योजना के तहत ऋण के लिए पात्र हैं।",
      benefits: "कम ब्याज दर पर कार्यशील पूंजी और कृषि उपकरण ऋण।",
      fullInfo: "KCC किसानों को त्वरित और सस्ते ऋण की सुविधा देता है।",
      website: "https://pmfby.gov.in/kcc",
    ),
    Scheme(
      name: "PM‑KUSUM",
      description:
          "सौर ऊर्जा आधारित सिंचाई प्रणालियों को बढ़ावा देने और ग्रिड से जुड़े सौर ऊर्जा संयंत्रों को प्रोत्साहित करने की योजना। जिन किसानों के खेतों में बिजली अनियमित है, वे पात्र हैं।",
      benefits: "सब्सिडी वाले सोलर पंप और ग्रिड जुड़ी ऊर्जा सुविधा।",
      fullInfo: "PM‑KUSUM सौर ऊर्जा आधारित सिंचाई प्रणाली को बढ़ावा देता है।",
      website: "https://mnre.gov.in/pm-kusum",
    ),
    Scheme(
      name: "e‑NAM (राष्ट्रीय कृषि बाजार)",
      description:
          "किसानों को ऑनलाइन मंडी से जोड़ने वाला एक डिजिटल प्लेटफॉर्म जो बेहतर मूल्य और पारदर्शी व्यापार सुनिश्चित करता है। पंजीकृत किसान और व्यापारी इसके लिए पात्र हैं।",
      benefits: "बेहतर मूल्य, पारदर्शी ट्रेडिंग, मध्यस्थता कम।",
      fullInfo: "e‑NAM किसानों को ऑनलाइन मंडी से जोड़ता है।",
      website: "https://enam.gov.in",
    ),
    Scheme(
      name: "मृदा स्वास्थ्य कार्ड योजना",
      description:
          "मिट्टी के स्वास्थ्य का मूल्यांकन करने और किसानों को उर्वरकों के उचित उपयोग पर मार्गदर्शन करने के लिए मिट्टी परीक्षण को बढ़ावा देता है। सभी किसान इस योजना के लिए पात्र हैं।",
      benefits: "उर्वरक एवं फसल चयन के लिए व्यक्तिगत रिपोर्ट।",
      fullInfo:
          "मृदा स्वास्थ्य कार्ड योजना मिट्टी परीक्षण और पोषण सुझाव देती है।",
      website: "https://soilhealth.dac.gov.in",
    ),
    Scheme(
      name: "RKVY‑RAFTAAR",
      description:
          "कृषि और संबद्ध क्षेत्रों में बुनियादी ढांचे को मजबूत करने और नवाचार को बढ़ावा देने के लिए राज्यों को वित्तीय सहायता प्रदान करता है। राज्य सरकारें और किसान पात्र हैं।",
      benefits: "परियोजना फंड, तकनीकी सहायता, प्रशिक्षण।",
      fullInfo:
          "RKVY‑RAFTAAR कृषि नवोन्मेषण और बुनियादी ढांचे को समर्थन देता है।",
      website: "https://rkvy.nic.in",
    ),
    Scheme(
      name: "NABARD – SC/ST किसानों हेतु योजनाएँ",
      description:
          "SC/ST समुदायों के किसानों को कृषि और ग्रामीण विकास गतिविधियों के लिए वित्तीय सहायता और प्रशिक्षण प्रदान करने वाली विशेष योजनाएँ। SC/ST किसान और उनके संगठन पात्र हैं।",
      benefits: "सब्सिडी, प्रशिक्षण, अवसंरचना विकास।",
      fullInfo: "NABARD SC/ST किसानों हेतु विशेष योजनाएँ प्रदान करता है।",
      website: "https://www.nabard.org",
    ),
    Scheme(
      name: "राष्ट्रीय बागवानी मिशन (NHM)",
      description:
          "बागवानी फसलों के उत्पादन और उत्पादकता को बढ़ाने, गुणवत्ता में सुधार करने और विपणन को सुविधाजनक बनाने में मदद करता है। बागवानी किसान और उत्पादक संगठन पात्र हैं।",
      benefits: "संरचना, प्रशिक्षण, सब्सिडी एवं विपणन सहायता।",
      fullInfo: "NHM बागवानी विकास हेतु व्यापक समर्थन देता है।",
      website: "https://www.nhm.gov.in",
    ),
    Scheme(
      name: "मनरेगा (MGNREGS)",
      description:
          "ग्रामीण परिवारों को एक वर्ष में 100 दिनों के मजदूरी रोजगार की गारंटी देने वाली एक कानूनी योजना। ग्रामीण क्षेत्रों में रहने वाला कोई भी वयस्क इसके लिए पात्र है।",
      benefits: "प्रति परिवार 100 दिन मजदूरी रोजगार।",
      fullInfo: "MGNREGS ग्रामीण क्षेत्रों में रोज़गार की गारंटी देता है।",
      website: "https://nrega.nic.in",
    ),
  ],
  'kn': [
    Scheme(
      name: "ರಾಷ್ಟ್ರೀಯ ಸುಸ್ಥಿರ ಕೃಷಿ ಮಿಷನ್ (NMSA)",
      description:
          "ಹವಾಮಾನ ಬದಲಾವಣೆ ಹೊಂದಾಣಿಕೆ ಕ್ರಮಗಳು, ನೀರಿನ ಬಳಕೆ ದಕ್ಷತೆ, ಮಣ್ಣಿನ ಆರೋಗ್ಯ ನಿರ್ವಹಣೆ ಮತ್ತು ಸಂಪನ್ಮೂಲ ಸಂರಕ್ಷಣೆ ಮೂಲಕ ಸುಸ್ಥಿರ ಕೃಷಿಯನ್ನು ಉತ್ತೇಜಿಸುತ್ತದೆ. ಮಳೆ ಆಧಾರಿತ ಪ್ರದೇಶ ಅಭಿವೃದ್ಧಿ ಮತ್ತು ಹವಾಮಾನ ಬದಲಾವಣೆ ಹೊಂದಾಣಿಕೆ ಮೇಲೆ ಗಮನ ಹರಿಸಲಾಗಿದೆ.",
      benefits: "ಹವಾಮಾನ-ಸ್ಥಿತಿಸ್ಥಾಪಕ ಕೃಷಿ ಮತ್ತು ಸುಸ್ಥಿರ ಅಭ್ಯಾಸಗಳಿಗೆ ಬೆಂಬಲ.",
      fullInfo:
          "NMSA ವಿಶೇಷವಾಗಿ ಮಳೆ ಆಧಾರಿತ ಪ್ರದೇಶಗಳಲ್ಲಿ ಸಮಗ್ರ ಕೃಷಿ, ನೀರಿನ ಬಳಕೆ ದಕ್ಷತೆ, ಮಣ್ಣಿನ ಆರೋಗ್ಯ ನಿರ್ವಹಣೆ ಮತ್ತು ಸಂಪನ್ಮೂಲ ಸಂರಕ್ಷಣೆ ಮೇಲೆ ಗಮನ ಹರಿಸಿ ಕೃಷಿ ಉತ್ಪಾದಕತೆಯನ್ನು ಹೆಚ್ಚಿಸುವ ಗುರಿಯನ್ನು ಹೊಂದಿದೆ.",
      website: "https://nmsa.dac.gov.in/",
    ),
    Scheme(
      name: "ಗ್ರಾಮೀಣ ಭಂಡಾರಣ ಯೋಜನೆ",
      description:
          "ರೈತರು ಕೃಷಿ ಉತ್ಪನ್ನಗಳು, ಸಂಸ್ಕರಿಸಿದ ಕೃಷಿ ಉತ್ಪನ್ನಗಳು ಮತ್ತು ಕೃಷಿ ಇನ್‌ಪುಟ್‌ಗಳನ್ನು ಸಂಗ್ರಹಿಸಲು ಸಹಾಯ ಮಾಡಲು ಗ್ರಾಮೀಣ ಪ್ರದೇಶಗಳಲ್ಲಿ ವೈಜ್ಞಾನಿಕ ಸಂಗ್ರಹಣಾ ಸಾಮರ್ಥ್ಯವನ್ನು ಸೃಷ್ಟಿಸುವುದು. ಗ್ರೇಡಿಂಗ್, ಗುಣಮಟ್ಟದ ನಿಯಂತ್ರಣ ಮತ್ತು ಮಾನದಂಡೀಕರಣವನ್ನು ಉತ್ತೇಜಿಸುತ್ತದೆ.",
      benefits: "ಸಂಗ್ರಹಣಾ ಮೂಲಸೌಕರ್ಯ ಮತ್ತು ಗುಣಮಟ್ಟ ನಿರ್ವಹಣೆ ಬೆಂಬಲ.",
      fullInfo:
          "ಕೃಷಿ-ಮಟ್ಟದ ಸಂಗ್ರಹಣಾ ಸಾಮರ್ಥ್ಯವನ್ನು ಸೃಷ್ಟಿಸುವ ಮೂಲಕ ಮತ್ತು ಕೊಯ್ಲಿನ ನಂತರದ ಸಾಲಗಳಿಗೆ ಬೆಂಬಲ ನೀಡುವ ಮೂಲಕ ಒತ್ತಡದ ಮಾರಾಟವನ್ನು ತಡೆಯುವುದು.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "ಸಮಗ್ರ ಕೃಷಿ ಮಾರುಕಟ್ಟೆ ಯೋಜನೆ (ISAM)",
      description:
          "ಮಾರುಕಟ್ಟೆ ಮೂಲಸೌಕರ್ಯವನ್ನು ಬಲಪಡಿಸುವುದು, ನವೀನ ಮಾರುಕಟ್ಟೆ ಪರಿಹಾರಗಳು ಮತ್ತು ಕೃಷಿ ಮಾರುಕಟ್ಟೆ ಮಾಹಿತಿ ಜಾಲದ ಮೂಲಕ ರೈತರನ್ನು ಮಾರುಕಟ್ಟೆಗಳೊಂದಿಗೆ ಸಂಯೋಜಿಸುವುದನ್ನು ಉತ್ತೇಜಿಸುತ್ತದೆ.",
      benefits: "ಮಾರುಕಟ್ಟೆ ಮೂಲಸೌಕರ್ಯ ಅಭಿವೃದ್ಧಿ ಮತ್ತು ಮಾಹಿತಿ ಸೇವೆಗಳು.",
      fullInfo:
          "ISAM ಆಧುನಿಕ ಮೂಲಸೌಕರ್ಯ ಮತ್ತು ಮಾಹಿತಿ ಹಂಚಿಕೆ ಮೂಲಕ ರೈತರನ್ನು ಮಾರುಕಟ್ಟೆಗಳೊಂದಿಗೆ ಸಂಯೋಜಿಸುತ್ತದೆ.",
      website: "https://dmi.gov.in/",
    ),
    Scheme(
      name: "ರಾಷ್ಟ್ರೀಯ ಸಾವಯವ ಕೃಷಿ ಯೋಜನೆ (NPOF)",
      description:
          "ಸಾವಯವ ಕೃಷಿ ಪದ್ಧತಿಗಳು, ಪ್ರಮಾಣೀಕರಣ ಪ್ರಕ್ರಿಯೆಗಳು ಮತ್ತು ಸಾವಯವ ಇನ್‌ಪುಟ್‌ಗಳ ಉತ್ಪಾದನೆಯನ್ನು ಉತ್ತೇಜಿಸುತ್ತದೆ. ತಾಂತ್ರಿಕ ಸಾಮರ್ಥ್ಯ ನಿರ್ಮಾಣವನ್ನು ಒದಗಿಸುತ್ತದೆ ಮತ್ತು ಸಾವಯವ ಇನ್‌ಪುಟ್ ಉತ್ಪಾದನಾ ಘಟಕಗಳಿಗೆ ಬೆಂಬಲ ನೀಡುತ್ತದೆ.",
      benefits: "ತರಬೇತಿ, ಪ್ರಮಾಣೀಕರಣ ಬೆಂಬಲ ಮತ್ತು ಸಾವಯವ ಇನ್‌ಪುಟ್ ಸಹಾಯ.",
      fullInfo:
          "NPOF ಸಾವಯವ ಕೃಷಿ ವಿಧಾನಗಳನ್ನು ಉತ್ತೇಜಿಸುತ್ತದೆ ಮತ್ತು ಸಾವಯವ ಕೃಷಿಗೆ ಬದಲಾಗುವ ರೈತರಿಗೆ ಬೆಂಬಲ ನೀಡುತ್ತದೆ.",
      website: "https://pgsindia-ncof.gov.in/",
    ),
    Scheme(
      name: "ಜಾನುವಾರು ವಿಮಾ ಯೋಜನೆ",
      description:
          "ರೈತರು ಮತ್ತು ಜಾನುವಾರು ಸಾಕುವವರಿಗೆ ಅವರ ಪ್ರಾಣಿಗಳ ಸಾವು ಅಥವಾ ಶಾಶ್ವತ ಅಂಗವೈಕಲ್ಯದಿಂದ ಉಂಟಾಗುವ ನಷ್ಟಕ್ಕೆ ವಿಮೆ ರಕ್ಷಣೆಯನ್ನು ಒದಗಿಸುತ್ತದೆ. ವಿಮೆಯನ್ನು ಸುಲಭವಾಗಿ ಪಡೆಯಲು ಪ್ರೀಮಿಯಂ ಪಾವತಿಗೆ ಸಬ್ಸಿಡಿ ನೀಡುತ್ತದೆ.",
      benefits: "ಸಬ್ಸಿಡಿ ಪ್ರೀಮಿಯಂಗಳೊಂದಿಗೆ ಜಾನುವಾರುಗಳಿಗೆ ವಿಮೆ ರಕ್ಷಣೆ.",
      fullInfo:
          "ವಿಮಾ ಬೆಂಬಲದ ಮೂಲಕ ಉತ್ಪಾದಕ ಜಾನುವಾರುಗಳ ಸಾವಿನಿಂದ ಉಂಟಾಗುವ ನಷ್ಟಗಳಿಂದ ರೈತರನ್ನು ರಕ್ಷಿಸುತ್ತದೆ.",
      website: "https://dahd.nic.in/",
    ),
    Scheme(
      name: "ಕೃಷಿ ವಿಸ್ತರಣೆ & ತಂತ್ರಜ್ಞಾನದ ರಾಷ್ಟ್ರೀಯ ಮಿಷನ್ (NMAET)",
      description:
          "ತಂತ್ರಜ್ಞಾನ ಪ್ರಸಾರದ ಮೂಲಕ ರೈತರಿಗೆ ಬೆಂಬಲ ನೀಡಲು ವಿಸ್ತರಣಾ ಯಂತ್ರಾಂಗವನ್ನು ಬಲಪಡಿಸುತ್ತದೆ. ಕೃಷಿ ಯಾಂತ್ರೀಕರಣ, ಸುಸ್ಥಿರ ಕೃಷಿ ಮತ್ತು ಸಸ್ಯ ರಕ್ಷಣೆ ಮೇಲೆ ಗಮನ ಹರಿಸುತ್ತದೆ.",
      benefits: "ತಂತ್ರಜ್ಞಾನ ಪ್ರವೇಶ, ತರಬೇತಿ ಮತ್ತು ವಿಸ್ತರಣಾ ಸೇವೆಗಳು.",
      fullInfo:
          "NMAET ಉತ್ತಮ ವಿಸ್ತರಣಾ ಸೇವೆಗಳು ಮತ್ತು ಸಾಮರ್ಥ್ಯ ನಿರ್ಮಾಣದ ಮೂಲಕ ರೈತರಿಗೆ ತಂತ್ರಜ್ಞಾನದ ತಲುಪನ್ನು ಖಚಿತಪಡಿಸುತ್ತದೆ.",
      website: "https://extensionreforms.dacnet.nic.in/",
    ),
    Scheme(
      name: "ಪ್ರಧಾನ ಮಂತ್ರಿ ಗ್ರಾಮ ಸಿಂಚಾಯಿ ಯೋಜನೆ (PMGSY)",
      description:
          "ಕೃಷಿ ಭೂಮಿಯಲ್ಲಿ ನೀರಿನ ಭೌತಿಕ ಪ್ರವೇಶವನ್ನು ಹೆಚ್ಚಿಸುತ್ತದೆ ಮತ್ತು ಖಚಿತ ನೀರಾವರಿಯ ಅಡಿಯಲ್ಲಿ ಕೃಷಿಯೋಗ್ಯ ಪ್ರದೇಶವನ್ನು ವಿಸ್ತರಿಸುತ್ತದೆ. ದಕ್ಷ ನೀರು ನಿರ್ವಹಣಾ ಪದ್ಧತಿಗಳು ಮತ್ತು ಸೂಕ್ಷ್ಮ ನೀರಾವರಿಯನ್ನು ಉತ್ತೇಜಿಸುತ್ತದೆ.",
      benefits: "ನೀರಾವರಿ ಮೂಲಸೌಕರ್ಯ ಮತ್ತು ನೀರು ನಿರ್ವಹಣೆ ಬೆಂಬಲ.",
      fullInfo:
          "PMGSY ಕೃಷಿಯಲ್ಲಿ ನೀರಾವರಿ ಪ್ರವೇಶ ಮತ್ತು ನೀರಿನ ಬಳಕೆ ದಕ್ಷತೆಯನ್ನು ಸುಧಾರಿಸುವುದರ ಮೇಲೆ ಗಮನ ಹರಿಸುತ್ತದೆ.",
      website: "https://pmgsy.nic.in/",
    ),
    Scheme(
      name: "ರಾಷ್ಟ್ರೀಯ ಕೃಷಿ ವಿಮಾ ಯೋಜನೆ (NAIS)",
      description:
          "ನೈಸರ್ಗಿಕ ವಿಕೋಪಗಳು, ಕೀಟಗಳು ಮತ್ತು ರೋಗಗಳಿಂದ ಬೆಳೆ ವಿಫಲವಾದ ಸಂದರ್ಭದಲ್ಲಿ ರೈತರಿಗೆ ಆರ್ಥಿಕ ನೆರವು ನೀಡುತ್ತದೆ. ವಿಶೇಷವಾಗಿ ವಿಪತ್ತು ವರ್ಷಗಳಲ್ಲಿ ಕೃಷಿ ಆದಾಯವನ್ನು ಸ್ಥಿರಗೊಳಿಸುತ್ತದೆ.",
      benefits: "ಬೆಳೆ ವಿಮೆ ರಕ್ಷಣೆ ಮತ್ತು ವಿಪತ್ತು ಪರಿಹಾರ.",
      fullInfo:
          "NAIS ಬೆಳೆ ನಷ್ಟಗಳಿಂದ ರೈತರನ್ನು ರಕ್ಷಿಸಿ ಆದಾಯವನ್ನು ಸ್ಥಿರಗೊಳಿಸಲು ಮತ್ತು ಸಾಲ ಅರ್ಹತೆಯನ್ನು ಖಚಿತಪಡಿಸಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.",
      website: "https://pmfby.gov.in/",
    ),
    Scheme(
      name: "ಪ್ರಧಾನ ಮಂತ್ರಿ ಕಿಸಾನ್ ಮಾನ್‌ಧನ್ ಯೋಜನೆ",
      description:
          "ಸಣ್ಣ ಮತ್ತು ಅತಿ ಸಣ್ಣ ರೈತರಿಗೆ 60 ವರ್ಷ ವಯಸ್ಸಿನ ನಂತರ ತಿಂಗಳ ಪಿಂಚಣಿ ನೀಡಲು ರೂಪಿಸಲಾದ ಪಿಂಚಣಿ ಯೋಜನೆ. 18 ರಿಂದ 40 ವರ್ಷ ವಯಸ್ಸಿನ ರೈತರು ನೋಂದಣಿಗೆ ಅರ್ಹರು.",
      benefits: "60 ವರ್ಷ ವಯಸ್ಸಿನ ನಂತರ ತಿಂಗಳ ಪಿಂಚಣಿ.",
      fullInfo:
          "PMKMY 60 ವರ್ಷ ವಯಸ್ಸಿನ ನಂತರ ಸಣ್ಣ ಮತ್ತು ಅತಿ ಸಣ್ಣ ರೈತರಿಗೆ ತಿಂಗಳಿಗೆ ರೂ.3,000 ಪಿಂಚಣಿ ನೀಡುತ್ತದೆ.",
      website: "https://www.pmkmy.gov.in/",
    ),
    Scheme(
      name: "ಪ್ರಧಾನ ಮಂತ್ರಿ ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ (PM‑KISAN)",
      description:
          "ಈ ಯೋಜನೆಯು ಎಲ್ಲಾ ಭೂಮಾಲೀಕ ರೈತ ಕುಟುಂಬಗಳಿಗೆ ವರ್ಷಕ್ಕೆ ₹6,000 ಆದಾಯ ಬೆಂಬಲವನ್ನು ನೀಡುತ್ತದೆ. ಈ ಹಣವನ್ನು ಮೂರು ಸಮಾನ ಕಂತುಗಳಲ್ಲಿ ನೇರವಾಗಿ ಅವರ ಬ್ಯಾಂಕ್ ಖಾತೆಗಳಿಗೆ ವರ್ಗಾಯಿಸಲಾಗುತ್ತದೆ. 2 ಹೆಕ್ಟೇರ್‌ವರೆಗೆ ಕೃಷಿ ಭೂಮಿ ಹೊಂದಿರುವ ಎಲ್ಲಾ ರೈತರು ಅರ್ಹರಾಗಿರುತ್ತಾರೆ.",
      benefits: "₹2,000 × 3 ಕಂತುಗಳಲ್ಲಿ DBT ಮೂಲಕ ವರ್ಷಕ್ಕೆ ₹6,000.",
      fullInfo:
          "PM‑KISAN ಸಣ್ಣ ಮತ್ತು ಮಾರುಕಟ್ತಿ ರೈತರಿಗೆ ವರ್ಷಕ್ಕೆ ₹6,000 ನೇರವಾಗಿ ಬ್ಯಾಂಕ್ ಖಾತೆಗೆ ಪಡೆಯುವ ಯೋಜನೆ.",
      website: "https://pmkisan.gov.in",
    ),
    Scheme(
      name: "ಪ್ರಧಾನ ಮಂತ್ರಿ ಫಸಲ್ ವಿಮಾ ಯೋಜನೆ (PMFBY)",
      description:
          "ನೈಸರ್ಗಿಕ ವಿಕೋಪಗಳು, ಕೀಟಗಳು ಮತ್ತು ರೋಗಗಳಿಂದ ಉಂಟಾಗುವ ಬೆಳೆ ನಷ್ಟದಿಂದ ರೈತರನ್ನು ರಕ್ಷಿಸಲು ಒಂದು ವಿಮಾ ಯೋಜನೆ. ಅಧಿಸೂಚಿತ ಬೆಳೆಗಳನ್ನು ಬೆಳೆಯುವ ಎಲ್ಲಾ ರೈತರು, ಪಾಲುದಾರರು ಸೇರಿದಂತೆ, ಈ ಯೋಜನೆಗೆ ಅರ್ಹರಾಗಿರುತ್ತಾರೆ.",
      benefits: "ಪ್ರೀಮಿಯಂ ಸಹಾಯತೆ ಮತ್ತು ಬೆಳೆ ನಷ್ಟದ ನಷ್ಟ ಪರಿಹಾರ.",
      fullInfo: "PMFBY ಪ್ರಕೃತಿಕ ವಿಪತ್ತುಗಳು, ಕೀಟಗಳು ಮತ್ತು ರೋಗಗಳಿಂದ ಬೆಳೆ ರಕ್ಷಣೆ.",
      website: "https://pmfby.gov.in",
    ),
    Scheme(
      name: "ಕಿಸಾನ್ ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್ (KCC)",
      description:
          "ರೈತರಿಗೆ ಅವರ ಕೃಷಿ ಮತ್ತು ಸಂಬಂಧಿತ ಚಟುವಟಿಕೆಗಳಿಗೆ ಸಕಾಲಿಕ ಮತ್ತು ಕಡಿಮೆ ಬಡ್ಡಿದರದಲ್ಲಿ ಸಾಲ ಒದಗಿಸುವ ಯೋಜನೆ. ಎಲ್ಲಾ ರೈತರು, ಪಶುಸಂಗೋಪನೆ ಮತ್ತು ಮೀನುಗಾರಿಕೆಯಲ್ಲಿ ತೊಡಗಿರುವವರು ಈ ಯೋಜನೆಗೆ ಅರ್ಹರಾಗಿರುತ್ತಾರೆ.",
      benefits: "ಕೃಷಿ ಕಾರ್ಯಚಟುವಟಿಕೆ ಮತ್ತು ಸಾಧನಗಳಿಗಾಗಿ ಸೌಲಭ್ಯಪೂರ್ಣ ಕ್ರೆಡಿಟ್.",
      fullInfo:
          "KCC ರೈತರಿಗೆ ತ್ವರಿತ ಮತ್ತು ಕಡಿಮೆ ಬಡ್ಡಿದರದ ಸಾಲವನ್ನು ಒದಗಿಸುವ ಯೋಜನೆ.",
      website: "https://pmfby.gov.in/kcc",
    ),
    Scheme(
      name: "PM‑KUSUM",
      description:
          "ಗ್ರಾಮೀಣ ಪ್ರದೇಶಗಳಲ್ಲಿ ಸೌರ ಪಂಪ್‌ಗಳನ್ನು ಸ್ಥಾಪಿಸಲು ಮತ್ತು ಗ್ರಿಡ್-ಸಂಪರ್ಕಿತ ಸೌರ ವಿದ್ಯುತ್ ಸ್ಥಾವರಗಳನ್ನು ಉತ್ತೇಜಿಸುವ ಯೋಜನೆ. ವಿದ್ಯುತ್ ಸಂಪರ್ಕವಿಲ್ಲದ ಅಥವಾ ಅಸ್ಥಿರ ವಿದ್ಯುತ್ ಪೂರೈಕೆ ಇರುವ ರೈತರು ಅರ್ಹರು.",
      benefits:
          "ವಿದ್ಯುತ್ ಬಳಕೆಯ ವೆಚ್ಚ ಕಡಿತ, ಅಧಿಕ ವಿದ್ಯುತ್ ಮಾರಾಟದಿಂದ ಹೆಚ್ಚುವರಿ ಆದಾಯ.",
      fullInfo:
          "PM‑KUSUM ಗ್ರಾಮೀಣ ಭಾಗಗಳಲ್ಲಿ ಸೌರ ಪಂಪ್ಸ್ ಮತ್ತು ಗ್ರಿಡ್ ಜೋಡಿಸಿದ ಸೌರ ವಿದ್ಯುತ್ ವ್ಯವಸ್ಥೆಯನ್ನು ಉತ್ತೇಜಿಸುವ ಕಾರ್ಯಕ್ರಮ.",
      website: "https://mnre.gov.in/pm-kusum",
    ),
    Scheme(
      name: "e‑NAM (ರಾಷ್ಟ್ರೀಯ ಕೃಷಿ ಮಾರುಕಟ್ಟೆ)",
      description:
          "ರೈತರಿಗೆ ತಮ್ಮ ಉತ್ಪನ್ನಗಳನ್ನು ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ಮಾರಾಟ ಮಾಡಲು ಡಿಜಿಟಲ್ ವೇದಿಕೆಯನ್ನು ಒದಗಿಸುತ್ತದೆ, ಇದು ಉತ್ತಮ ಬೆಲೆ ಮತ್ತು ಪಾರದರ್ಶಕ ವಹಿವಾಟನ್ನು ಖಚಿತಪಡಿಸುತ್ತದೆ. ನೋಂದಾಯಿತ ರೈತರು ಮತ್ತು ವ್ಯಾಪಾರಿಗಳು ಅರ್ಹರು.",
      benefits:
          "ಮ minh karā jatiye mūlya, madhyasthal mali māḍuvaṃ teesādoḷiligaḷa kamiḍu.",
      fullInfo:
          "e‑NAM ರೈತರು ತಮ್ಮ ಕೃಷಿ ಉತ್ಪನ್ನಗಳನ್ನು ಆನ್ಲೈನ್ ಮಾರಾಟ ಮಾಡಲು ಹಂತ ಸರಳ ಡಿಜಿಟಲ್ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್.",
      website: "https://enam.gov.in",
    ),
    Scheme(
      name: "ಮಣ್ಣು ಆರೋಗ್ಯ ಚೀಟಿ ಯೋಜನೆ",
      description:
          "ಮಣ್ಣಿನ ಆರೋಗ್ಯವನ್ನು ಮೌಲ್ಯಮಾಪನ ಮಾಡಲು ಮತ್ತು ರೈತರಿಗೆ ರಸಗೊಬ್ಬರಗಳ ಸೂಕ್ತ ಬಳಕೆಯ ಬಗ್ಗೆ ಮಾರ್ಗದರ್ಶನ ನೀಡಲು ಮಣ್ಣಿನ ಪರೀಕ್ಷೆಯನ್ನು ಉತ್ತೇಜಿಸುತ್ತದೆ. ಎಲ್ಲಾ ರೈತರು ಈ ಯೋಜನೆಗೆ ಅರ್ಹರು.",
      benefits: "ಒಳ್ಳೆಯ ಬೆಳೆ ಆಯ್ಕೆ ಮತ್ತು ಪೋಷಕಾಂಶ ಸಿದ್ಧಪಡಿಸಬಹುದು.",
      fullInfo:
          "ಮಣ್ಣು ಆರೋಗ್ಯ ಚೀಟಿ ಯೋಜನೆ ಮಣ್ಣಿನ ಗುಣಮಟ್ಟ ಪರೀಕ್ಷೆ ಮತ್ತು ಸಂಪೂರ್ಣ ಪೋಷಕಾಂಶ ನಿರ್ವಹಣೆ ಸಲಹೆ.",
      website: "https://soilhealth.dac.gov.in",
    ),
    Scheme(
      name: "RKVY‑RAFTAAR",
      description:
          "ಕೃಷಿ ಮತ್ತು ಸಂಬಂಧಿತ ಕ್ಷೇತ್ರಗಳಲ್ಲಿ ಮೂಲಸೌಕರ್ಯವನ್ನು ಬಲಪಡಿಸಲು ಮತ್ತು ನಾವೀನ್ಯತೆಯನ್ನು ಉತ್ತೇಜಿಸಲು ರಾಜ್ಯಗಳಿಗೆ ಹಣಕಾಸಿನ ನೆರವು ನೀಡುತ್ತದೆ. ರಾಜ್ಯ ಸರ್ಕಾರಗಳು ಮತ್ತು ರೈತರು ಅರ್ಹರು.",
      benefits: "ಯೋಜನಾ ನಿಧಿ, ತಂತ್ರಜ್ಞಾನ ಸಹಾಯ ಮತ್ತು ತರಬೇತಿ.",
      fullInfo:
          "RKVY‑RAFTAAR ಕೃಷಿ ತಂತ್ರಜ್ಞಾನ, ನವೀನತೆ ಮತ್ತು ಮೂಲಸೌಕರ್ಯ ಅಭಿವೃದ್ಧಿ ಯೋಜನೆ.",
      website: "https://rkvy.nic.in",
    ),
    Scheme(
      name: "NABARD – SC/ST ರೈತ ಯೋಜನೆಗಳು",
      description:
          "SC/ST ಸಮುದಾಯಗಳ ರೈತರಿಗೆ ಕೃಷಿ ಮತ್ತು ಗ್ರಾಮೀಣಾಭಿವೃದ್ಧಿ ಚಟುವಟಿಕೆಗಳಿಗೆ ಹಣಕಾಸಿನ ನೆರವು ಮತ್ತು ತರಬೇತಿ ನೀಡುವ ವಿಶೇಷ ಯೋಜನೆಗಳು. SC/ST ರೈತರು ಮತ್ತು ಅವರ ಸಂಸ್ಥೆಗಳು ಅರ್ಹರು.",
      benefits: "ಧನ್ಯವಾದ, ತರಬೇತಿ ಮತ್ತು ಮೂಲಸೌಕರ್ಯ ಅಭಿವೃದ್ಧಿ.",
      fullInfo: "NABARD SC/ST ರೈತ ಕುಟುಂಬಗಳಿಗೆ ವಿಶೇಷ ಸಹಾಯ ನೀಡುವ ಯೋಜನೆಗಳ ಸಂಚಿಕೆ.",
      website: "https://www.nabard.org",
    ),
    Scheme(
      name: "ರಾಷ್ಟ್ರೀಯ ತೋಟಗಾರಿಕಾ ಮಿಷನ್ (NHM)",
      description:
          "ತೋಟಗಾರಿಕಾ ಬೆಳೆಗಳ ಉತ್ಪಾದನೆ ಮತ್ತು ಉತ್ಪಾದಕತೆಯನ್ನು ಹೆಚ್ಚಿಸಲು, ಗುಣಮಟ್ಟವನ್ನು ಸುಧಾರಿಸಲು ಮತ್ತು ಮಾರುಕಟ್ಟೆಯನ್ನು ಸುಲಭಗೊಳಿಸಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ. ತೋಟಗಾರಿಕಾ ರೈತರು ಮತ್ತು ಉತ್ಪಾದಕ ಸಂಸ್ಥೆಗಳು ಅರ್ಹರು.",
      benefits: "ಹಣಕಾಸು ಸಹಾಯ, ತರಬೇತಿ ಮತ್ತು ಮಾರ್ಕೆಟ್ ಲಿಂಕ್.",
      fullInfo: "NHM ಹಣ್ಣು, ಹೂವು ಮತ್ತು ಮಸಾಲೆ ಉತ್ಪಾದನೆಗೆ ಉತ್ತೇಜನೆ.",
      website: "https://www.nhm.gov.in",
    ),
    Scheme(
      name: "ಮಹಾತ್ಮಾ ಗಾಂಧಿ ರಾಷ್ಟ್ರೀಯ ಗ್ರಾಮೀಣ ಉದ್ಯೋಗ ಖಾತ್ರಿ ಯೋಜನೆ (MGNREGS)",
      description:
          "ಗ್ರಾಮೀಣ ಕುಟುಂಬಗಳಿಗೆ ಒಂದು ವರ್ಷದಲ್ಲಿ 100 ದಿನಗಳ ವೇತನ ಸಹಿತ ಉದ್ಯೋಗವನ್ನು ಖಾತರಿಪಡಿಸುವ ಕಾನೂನುಬದ್ಧ ಯೋಜನೆ. ಗ್ರಾಮೀಣ ಪ್ರದೇಶಗಳಲ್ಲಿ ವಾಸಿಸುವ ಯಾವುದೇ ವಯಸ್ಕರು ಇದಕ್ಕೆ ಅರ್ಹರು.",
      benefits: "ವಿರಾಮದ ಕೆಲಸದ ಮೂಲಕ ವಾರ್ಷಿಕ ಆದಾಯ.",
      fullInfo:
          "MGNREGS ಗ್ರಾಮೀಣ ಪ್ರದೇಶಗಳಲ್ಲಿ ಪ್ರತೀ ಕುಟುಂಬಕ್ಕೆ ವರ್ಷಕ್ಕೆ 100 ದಿನಗಳ ಕೆಲಸದ ಭರವಸೆ.",
      website: "https://nrega.nic.in",
    ),
  ],
};
final List<Scheme> dummySchemes = [];
