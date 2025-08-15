import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class YearlyPlanPage extends StatefulWidget {
  final String userState; // User's state (e.g., "Maharashtra")

  const YearlyPlanPage({Key? key, required this.userState}) : super(key: key);

  @override
  _YearlyPlanPageState createState() => _YearlyPlanPageState();
}

class _YearlyPlanPageState extends State<YearlyPlanPage> {
  // --- Configuration ---
  // Replace with your computer's IP address
  final String _apiUrl = "http://192.168.89.31:5000/generate_demand_plan"; 

  // --- State Variables ---
  Map<String, dynamic>? _yearlyPlan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchYearlyPlan();
  }

  // --- API Call ---
  Future<void> _fetchYearlyPlan() async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'state': widget.userState}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _yearlyPlan = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load plan. Server returned error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to connect to the server. Please ensure the server is running and you are on the same network.";
        _isLoading = false;
      });
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Yearly Farming Plan'),
        backgroundColor: Colors.green,
      ),
      body: _buildBody(),
    );
  }

  // --- Body Widget ---
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Generating your personalized plan..."),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_yearlyPlan == null || _yearlyPlan!.isEmpty) {
      return const Center(child: Text("No plan could be generated for your location."));
    }

    // Display the plan using a ListView
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: _yearlyPlan!.entries.map((entry) {
        return CropSuggestionCard(
          season: entry.key,
          cropData: entry.value,
        );
      }).toList(),
    );
  }
}

// --- Crop Suggestion Card Widget ---
class CropSuggestionCard extends StatelessWidget {
  final String season;
  final Map<String, dynamic> cropData;

  const CropSuggestionCard({
    Key? key,
    required this.season,
    required this.cropData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Text(
              season,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            // --- Crop Name ---
            Text(
              cropData['crop_name'] ?? 'N/A',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            // --- Key Metrics ---
            _buildInfoRow(Icons.trending_up, "Demand Growth", cropData['demand_growth_vs_last_year'] ?? '0.00%'),
            _buildInfoRow(Icons.attach_money, "Market Price", "${cropData['market_price_per_qtl']}/qtl"),
            _buildInfoRow(Icons.eco, "Predicted Yield", "${cropData['predicted_yield_per_ha']} tons/ha"),
            _buildInfoRow(Icons.account_balance_wallet, "Est. Revenue", cropData['estimated_revenue'] ?? 'Rs. 0.00'),
            const SizedBox(height: 15),

            // --- AI Advice ---
            const Text(
              "AI Farming Advice:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 5),
            Text(
              cropData['ai_advice'] ?? 'No advice available.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}