import 'package:flutter/material.dart';
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

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<Map<String, dynamic>> _reminders = [
    {
      'medicine': 'Paracetamol',
      'time': 'Morning',
      'isBeforeMeal': true,
      'days': {'Monday', 'Wednesday', 'Friday'},
    },
    {
      'medicine': 'Vitamin C',
      'time': 'Afternoon',
      'isBeforeMeal': false,
      'days': {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'},
    },
  ];

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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.medication),
                    title: Text(reminder['medicine']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${reminder['time']} - ${reminder['isBeforeMeal'] ? 'Before Meal' : 'After Meal'}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Days: ${reminder['days'].join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _reminders.removeAt(index);
                        });
                      },
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

  void _addReminder() {
    if (_formKey.currentState!.validate() && _selectedDays.isNotEmpty) {
      setState(() {
        _reminders.add({
          'medicine': _medicineController.text,
          'time': _selectedTime,
          'isBeforeMeal': _isBeforeMeal,
          'days': Set<String>.from(_selectedDays),
        });
        _medicineController.clear();
        _selectedDays.clear();
      });
    } else if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }
} 