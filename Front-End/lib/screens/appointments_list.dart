import 'package:flutter/material.dart';
import '../services/myAppointmentService.dart';
import '../services/videoCallService.dart';
import './video_call_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final status = appointment['status'] ?? 'unknown';
    final date = appointment['available_date'] ?? '';
    final time = appointment['time_slot'] ?? '';
    final appointmentId = appointment['appointment_id'];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: $date'),
                    Text('Time: $time'),
                  ],
                ),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      startVideoCall(context, appointmentId, widget.role == 'doctor');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.video,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
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

  void startVideoCall(BuildContext context, int appointmentId, bool isDoctor) async {
    final data = await fetchVideoCallData(appointmentId);

    if (data != null) {
      final uid = isDoctor ? data.doctorUid : data.patientUid;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            channelName: data.channelName,
            uid: uid,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start video call')),
      );
    }
  }
}
