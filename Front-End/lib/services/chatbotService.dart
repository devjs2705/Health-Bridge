import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotService {
  // This function fetches the chatbot URL from your backend
  Future<String> getChatbotUrl() async {
    try {
      // Send a GET request to your backend to get the chatbot URL
      final response = await http.get(Uri.parse('http://192.168.29.144:5000/api/chatbot'));  // Updated URL to your backend

      if (response.statusCode == 200) {
        // If the response is successful, parse the response body (JSON)
        final data = json.decode(response.body);  // Decode the JSON response
        return data['url'];  // Return the 'url' from the response JSON
      } else {
        throw Exception('Failed to load chatbot URL');
      }
    } catch (e) {
      // Catch any errors
      throw Exception('Error: $e');
    }
  }
}
