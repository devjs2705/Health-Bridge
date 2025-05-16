import 'package:flutter/material.dart';
import '../services/authService.dart';
import '../services/medicineReminderService.dart';
import '../services/notificationService.dart';
import '../widgets/keyboard_aware_scroll_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


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
  late final int patientId;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
    print(AuthService.id);
    patientId = int.parse(AuthService.id);
    checkScheduledNotifications();
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
                  style:
                  TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
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
                final beforeMeal =
                (reminder['before_meal'] == true || reminder['before_meal'] == 1)
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
      final success = await MedicineReminderService.addReminder(
        patientId: patientId,
        medicineName: _medicineController.text.trim(),
        shift: _selectedTime,
        beforeMeal: _isBeforeMeal,
        days: _selectedDays.toList(),
      );

      if (success) {
        _medicineController.clear();
        _selectedDays.clear();
        await _loadReminders();

        if (success) {
          // Schedule notifications locally
          final timeOfDay = _getTimeOfDayFromShift(_selectedTime, !_isBeforeMeal);
          final weekdays = _getWeekdaysFromSelectedDays(_selectedDays.toList());

          await NotificationService().scheduleMedicineReminder(
            id: patientId, // you can add a unique ID scheme here, maybe patientId + timestamp
            medicineName: _medicineController.text.trim(),
            timeOfDay: timeOfDay,
            weekdays: weekdays,
            afterMeal: !_isBeforeMeal, // adjust if needed, your service expects afterMeal bool
          );

          _medicineController.clear();
          _selectedDays.clear();
          await _loadReminders();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder added successfully')),
          );
        }


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder added successfully')),
        );
      } else {
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
      final medicineReminders =
      await MedicineReminderService.getReminders(patientId);

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

  TimeOfDay _getTimeOfDayFromShift(String shift, bool afterMeal) {
    // Define base times for each shift
    late TimeOfDay baseTime;

    switch (shift.toLowerCase()) {
      case 'morning':
        baseTime = const TimeOfDay(hour: 7, minute: 30);
        break;
      case 'afternoon':
        baseTime = const TimeOfDay(hour: 13, minute: 30);
        break;
      case 'night':
        baseTime = const TimeOfDay(hour: 20, minute: 0);
        break;
      default:
        baseTime = const TimeOfDay(hour: 9, minute: 0);
    }

    // Adjust time by ±30 minutes
    final offsetMinutes = afterMeal ? 30 : -30;
    final totalMinutes = baseTime.hour * 60 + baseTime.minute + offsetMinutes;

    final adjustedHour = (totalMinutes ~/ 60) % 24;
    final adjustedMinute = totalMinutes % 60;

    return TimeOfDay(hour: adjustedHour, minute: adjustedMinute);
  }


  List<int> _getWeekdaysFromSelectedDays(List<String> selectedDays) {
    const dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    return selectedDays.map((day) => dayMap[day]!).toList();
  }

  Future<void> checkScheduledNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (var notification in pendingNotificationRequests) {
      print('ID: ${notification.id}');
      print('Title: ${notification.title}');
      print('Body: ${notification.body}');
      print('Payload: ${notification.payload}');
    }

    if (pendingNotificationRequests.isEmpty) {
      print("No scheduled notifications");
    }
  }


  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }
}
