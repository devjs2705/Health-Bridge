import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentService {
  static const String baseUrl = 'http://192.168.29.144:5000';

  static Future<List<Map<String, dynamic>>> fetchDoctors(String specialization) async {
    final url = Uri.parse('$baseUrl/api/patient/doctors/$specialization');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<Map<String, dynamic>>((doc) => {
        'doctor_id': doc['doctor_id']?.toString() ?? '',
        'name': doc['name'] ?? 'Unknown',
      }).toList();
    } else {
      throw Exception('Failed to fetch doctors');
    }
  }

  static Future<Map<String, List<Map<String, dynamic>>>> fetchAvailableSlots(int doctorId) async {
    final url = Uri.parse('$baseUrl/api/patient/doctorAvailability/$doctorId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map<String, List<Map<String, dynamic>>> availability = {};
      (data['availability'] as Map<String, dynamic>).forEach((key, value) {
        availability[key] = List<Map<String, dynamic>>.from(value);
      });
      return availability;
    } else {
      throw Exception('Failed to fetch time slots');
    }
  }

  static Future<void> bookAppointment({
    required String doctorId,
    required String patientId,
    required String availabilityId,
    required String channelName,
    required int doctor_uid,
    required int patient_uid
  }) async {
    final url = Uri.parse('$baseUrl/api/patient/bookAppointment');

    print("Appointment booking patinet id: " +  patientId);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "doctorId": doctorId,
        "patientId": patientId,
        "availabilityId": availabilityId,
        "channelName": channelName,
        "doctor_uid": doctor_uid,
        "patient_uid": patient_uid
      }),
    );

    if (response.statusCode != 201) {
      final res = jsonDecode(response.body);
      throw Exception(res['message'] ?? 'Booking failed');
    }
  }

}
