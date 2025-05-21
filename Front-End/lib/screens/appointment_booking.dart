import 'dart:math';

import 'package:flutter/material.dart';
import '../services/appointmentService.dart';
import '../services/authService.dart';

class AppointmentBooking extends StatefulWidget {
  const AppointmentBooking({super.key});

  @override
  State<AppointmentBooking> createState() => _AppointmentBookingState();
}

class _AppointmentBookingState extends State<AppointmentBooking> {
  int _currentStep = 0;
  String? _selectedSpecialty;
  Map<String, dynamic>? _selectedDoctor;
  String? _selectedDateStr;
  Map<String, dynamic>? _selectedSlot;

  List<String> _specialties = [
    'ENT',
    'Cardiologist',
    'Pediatrician',
    'Dermatologist',
    'Orthopedist',
    'General Physician',
  ];

  List<Map<String, dynamic>> _doctors = [];
  Map<String, List<Map<String, dynamic>>> _timeSlots = {};

  bool _isLoadingDoctors = false;
  bool _isLoadingTimeSlots = false;

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedSpecialty != null;
      case 1:
        return _selectedDoctor != null;
      case 2:
        return _selectedDateStr != null && _selectedSlot != null;
      default:
        return false;
    }
  }

  void _handleContinue() async {
    if (_currentStep == 0 && _selectedSpecialty != null) {
      setState(() => _isLoadingDoctors = true);
      try {
        final doctors = await AppointmentService.fetchDoctors(_selectedSpecialty!);
        setState(() {
          _doctors = doctors;
          _selectedDoctor = null;
          _isLoadingDoctors = false;
          if (_doctors.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No doctors available for this specialization')),
            );
          } else {
            _currentStep++;
          }
        });
      } catch (e) {
        setState(() => _isLoadingDoctors = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading doctors: $e')));
      }
    } else if (_currentStep == 1 && _selectedDoctor != null) {
      setState(() => _currentStep++);
      _loadTimeSlots();
    } else if (_currentStep == 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specialty: $_selectedSpecialty'),
              Text('Doctor: ${_selectedDoctor!['name'] ?? 'Unknown'}'),
              Text('Date: $_selectedDateStr'),
              Text('Time: ${_selectedSlot!['time_slot']}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  String patientId = AuthService.id;
                  String channelName = DateTime.now().millisecondsSinceEpoch.toString();;
                  int doctor_uid = generateRandomUid();
                  int patient_uid = generateRandomUid();
                  await AppointmentService.bookAppointment(
                    doctorId: _selectedDoctor!['doctor_id'].toString(),
                    patientId: patientId,
                    availabilityId: _selectedSlot!['availability_id'].toString(),
                    channelName: channelName,
                    doctor_uid: doctor_uid,
                    patient_uid: patient_uid
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment booked!')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }

  int generateRandomUid() {
    final random = Random();
    return random.nextInt(1000000); // Generates a random number between 0 and 999,999
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedDoctor != null) {
      setState(() => _isLoadingTimeSlots = true);
      try {
        final slots = await AppointmentService.fetchAvailableSlots(
          int.parse(_selectedDoctor!['doctor_id']),
        );
        setState(() {
          _timeSlots = slots;
          _selectedDateStr = null;
          _selectedSlot = null;
          _isLoadingTimeSlots = false;
        });
      } catch (e) {
        setState(() => _isLoadingTimeSlots = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading slots: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _canContinue() ? _handleContinue : null,
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            title: const Text('Choose Specialty'),
            content: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final specialty = _specialties[index];
                return Card(
                  color: _selectedSpecialty == specialty
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : null,
                  child: InkWell(
                    onTap: () => setState(() => _selectedSpecialty = specialty),
                    child: Center(
                      child: Text(
                        specialty,
                        style: TextStyle(
                          fontWeight: _selectedSpecialty == specialty
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Select Doctor'),
            content: _isLoadingDoctors
                ? const CircularProgressIndicator()
                : _doctors.isEmpty
                ? const Text(
              "No doctors available for this specialization.",
              style: TextStyle(color: Colors.red),
            )
                : Column(
              children: _doctors.map((doctor) {
                final name = doctor['name'] ?? 'Unknown';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(name),
                    trailing: ElevatedButton(
                      onPressed: () => setState(() => _selectedDoctor = doctor),
                      child: Text(_selectedDoctor == doctor ? 'Selected' : 'Select'),
                    ),
                  ),
                );
              }).toList(),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Select Time Slot'),
            content: _isLoadingTimeSlots
                ? const CircularProgressIndicator()
                : _timeSlots.isEmpty
                ? const Text("No time slots available for this doctor.")
                : Column(
              children: _timeSlots.entries.map((entry) {
                final date = entry.key;
                final slots = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          date,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: slots.map((slot) {
                            return ChoiceChip(
                              label: Text(slot['time_slot']),
                              selected: _selectedSlot == slot,
                              onSelected: (_) {
                                setState(() {
                                  _selectedDateStr = date;
                                  _selectedSlot = slot;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            isActive: _currentStep >= 2,
          ),

        ],
      ),
    );
  }
}
