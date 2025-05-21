import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl =
      "http://192.168.29.144:5000"; // replace with your IP if testing on real device
  static String id = "";
  static String role = "";

  static Future<String> signup({
    required String password,
    required String role,
    required String name,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    print("➡️ Making POST request to $url");
    print("📦 Payload: ${jsonEncode({
          "password": password,
          "role": role,
          "name": name,
          "email": email,
        })}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "password": password,
        "role": role,
        "name": name,
        "email": email,
      }),
    );

    print("✅ Response status: ${response.statusCode}");
    print("📩 Response body: ${response.body}");

    if (response.statusCode == 201) {
      return "Signup successful";
    } else {
      final res = jsonDecode(response.body);
      throw Exception(res['message'] ?? "Signup failed");
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password, "role": role}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int? patientId = data['patientId'];
      int? doctorId = data['doctorId'];

      if(patientId != null) {
        AuthService.role = "patient";
        AuthService.id = patientId.toString();
        print(AuthService.id);
      }
      else {
        AuthService.role = "doctor";
        AuthService.id = doctorId.toString();
      }

      print(patientId);
      print(doctorId);

      return jsonDecode(
          response.body); // contains user data like user_id, role, etc.
    } else {
      final res = jsonDecode(response.body);
      throw Exception(res['message'] ?? "Login failed");
    }
  }
}
