import 'package:flutter/material.dart';

class FinalConfirmationPage extends StatelessWidget {
  final String languageCode;
  final String name;
  final String phone;
  final String land;
  final String crops;
  final String state;

  const FinalConfirmationPage({
    super.key,
    required this.languageCode,
    required this.name,
    required this.phone,
    required this.land,
    required this.crops,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $name', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Phone: $phone', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text(
                  'Landholdings: $land acres',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text('Crops: $crops', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('State: $state', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Finish', style: TextStyle(fontSize: 18)),
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
