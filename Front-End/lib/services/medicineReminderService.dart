import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicineReminderService {
  static const String baseUrl = 'http://192.168.29.144:5000'; // Replace with your actual base URL or IP

  /// Add a new medicine reminder
  static Future<bool> addReminder({
    required int patientId,
    required String medicineName,
    required String shift,
    required bool beforeMeal,
    required List<String> days,
  }) async {
    final url = Uri.parse('$baseUrl/api/patient/medicineReminder');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'patient_id': patientId,
        'medicine_name': medicineName,
        'shift': shift,
        'before_meal': beforeMeal,
        'days': days,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error adding reminder: ${response.body}");
      return false;
    }
  }

  /// Get all reminders for a patient
  static Future<List<Map<String, dynamic>>> getReminders(int patientId) async {
    final url = Uri.parse('$baseUrl/api/patient/medicineReminder/$patientId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("Error fetching reminders: ${response.body}");
      return [];
    }
  }
}
