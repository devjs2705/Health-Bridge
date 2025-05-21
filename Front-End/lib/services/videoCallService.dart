import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/videoCallData.dart';

Future<VideoCallData?> fetchVideoCallData(int appointmentId) async {
  final url = Uri.parse('http://192.168.29.144:5000/api/appointment/videoCall/$appointmentId');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return VideoCallData.fromJson(jsonDecode(response.body));
    } else {
      print('❌ API call failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  return null;
}
