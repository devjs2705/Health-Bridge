import 'dart:convert';
import 'package:http/http.dart' as http;

class MyAppointmentService {
  static const String baseUrl = "http://192.168.29.144:5000/api";

  // Fetch appointments based on user role
  static Future<List<Map<String, dynamic>>> fetchAppointments({
    required String role,
    required int id,
  }) async {
    final url = role == 'doctor'
        ? "$baseUrl/doctor/appointments/$id"
        : "$baseUrl/patient/appointments/$id";

    try {
      print(url);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print("Error fetching appointments: $e");
      rethrow;
    }
  }
}
