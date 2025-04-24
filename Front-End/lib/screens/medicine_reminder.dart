import 'package:flutter/material.dart';
import '../services/authService.dart';
import '../services/medicineReminderService.dart';
import '../widgets/keyboard_aware_scroll_view.dart';

class MedicineReminder extends StatefulWidget {
  const MedicineReminder({super.key});

  @override
  State<MedicineReminder> createState() => _MedicineReminderState();
}

class _MedicineReminderState extends State<MedicineReminder> {
  final _formKey = GlobalKey<FormState>();
  final _medicineController = TextEditingController();
  String _selectedTime = 'Morning';
  bool _isBeforeMeal = true;
  final Set<String> _selectedDays = {};
  final int patientId = int.parse(AuthService.id);

  List<Map<String, dynamic>> reminders = [];

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
      ),
      body: KeyboardAwareScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Reminder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _medicineController,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medicine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTime,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Morning', 'Afternoon', 'Night']
                        .map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTime = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Before Meal'),
                    value: _isBeforeMeal,
                    onChanged: (value) {
                      setState(() {
                        _isBeforeMeal = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Days',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _days.map((day) {
                      return FilterChip(
                        label: Text(day),
                        selected: _selectedDays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addReminder,
                      child: const Text('Add Reminder'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            reminders.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No reminders yet. Add one!',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                final medicine = reminder['medicine_name'] ?? 'Unknown';
                final shift = reminder['shift']?.toString().isNotEmpty == true
                    ? reminder['shift']
                    : 'Time not set';
                final beforeMeal = (reminder['before_meal'] == 1)
                    ? 'Before Meal'
                    : 'After Meal';
                final days = (reminder['days'] is List)
                    ? (reminder['days'] as List).join(', ')
                    : 'No days selected';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.medication),
                    title: Text(medicine),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$shift - $beforeMeal'),
                        const SizedBox(height: 4),
                        Text(
                          'Days: $days',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addReminder() async {
    if (_formKey.currentState!.validate() && _selectedDays.isNotEmpty) {
      try {
        var response = await MedicineReminderService.addReminder(
          patientId: int.parse(AuthService.id),
          medicineName: _medicineController.text,
          shift: _selectedTime,
          beforeMeal: _isBeforeMeal,
          days: _selectedDays.toList(),
        );

        print(response);

        _medicineController.clear();
        _selectedDays.clear();

        await _loadReminders();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder added successfully')),
        );
      } catch (e) {
        print("Error adding reminder: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add reminder')),
        );
      }
    } else if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
    }
  }

  Future<void> _loadReminders() async {
    try {
      final medicineReminders = await MedicineReminderService.getReminders(
        int.parse(AuthService.id),
      );

      setState(() {
        reminders
          ..clear()
          ..addAll(medicineReminders);
      });
    } catch (e) {
      print("Error loading reminders: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load reminders')),
      );
    }
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }
}
