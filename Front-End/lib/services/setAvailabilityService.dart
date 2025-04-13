import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AvailabilityService {
  static Future<bool> setAvailability({
    required int doctorId,
    required DateTime availableDate,
    required List<String> timeSlots,
  }) async {
    final url = Uri.parse('http://192.168.29.144:5000/api/doctor/setAvailability');
    final formattedDate = DateFormat('yyyy-MM-dd').format(availableDate);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'doctorId': doctorId,
        'availableDate': formattedDate,
        'timeSlots': timeSlots,
      }),
    );
    return true;

    if (response.statusCode != 200) {
      throw Exception('Failed to set availability');
    }
  }

  static Future<Map<String, dynamic>> fetchDoctorAvailability(int doctorId) async {
    final url = Uri.parse('http://192.168.29.144:5000/api/patient/doctorAvailability/$doctorId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['availability'];
    } else {
      throw Exception('Failed to fetch availability');
    }
  }
}
