import 'package:flutter/material.dart';
import '../services/myAppointmentService.dart';

class AppointmentsList extends StatefulWidget {
  final String role; // 'doctor' or 'patient'
  final int userId;

  const AppointmentsList({super.key, required this.role, required this.userId});

  @override
  State<AppointmentsList> createState() => _AppointmentsListState();
}

class _AppointmentsListState extends State<AppointmentsList> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    try {
      final data = await MyAppointmentService.fetchAppointments(
        role: widget.role,
        id: widget.userId,
      );
      setState(() {
        appointments = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : appointments.isEmpty
          ? const Center(child: Text('No appointments found'))
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    // Decide common fields
    final status = appointment['status'] ?? 'unknown';
    final date = appointment['available_date'] ?? '';
    final time = appointment['time_slot'] ?? '';

    // Dynamic values based on role
    final name = widget.role == 'doctor'
        ? appointment['patient_name']
        : appointment['doctor_name'];
    final subtitle = widget.role == 'doctor'
        ? 'Patient: $name'
        : 'Doctor: $name';

    final specialization = appointment['specialization'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  specialization.isNotEmpty ? specialization : 'Appointment',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            Text('Date: $date'),
            Text('Time: $time'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Optional: View details logic
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
      case 'booked':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
