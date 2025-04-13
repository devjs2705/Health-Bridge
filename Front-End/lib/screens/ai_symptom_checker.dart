import 'package:flutter/material.dart';

class AISymptomChecker extends StatefulWidget {
  const AISymptomChecker({super.key});

  @override
  State<AISymptomChecker> createState() => _AISymptomCheckerState();
}

class _AISymptomCheckerState extends State<AISymptomChecker> {
  final _symptomController = TextEditingController();
  String? _aiResponse;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Symptom Checker'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe your symptoms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Example: "I have a fever and headache for the last 2 days"',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _symptomController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter your symptoms here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkSymptoms,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Check Symptoms'),
                ),
              ),
              if (_aiResponse != null) ...[
                const SizedBox(height: 32),
                const Text(
                  'AI Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_aiResponse!),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to doctor recommendation
                          },
                          icon: const Icon(Icons.medical_services),
                          label: const Text('Find Recommended Doctors'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _checkSymptoms() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _aiResponse = 'Based on your symptoms, you may be experiencing a common cold or flu. '
            'It is recommended to:\n\n'
            '1. Rest and stay hydrated\n'
            '2. Take over-the-counter medications for fever and pain\n'
            '3. Monitor your temperature\n\n'
            'If symptoms persist for more than 3 days, please consult a doctor.';
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }
} 