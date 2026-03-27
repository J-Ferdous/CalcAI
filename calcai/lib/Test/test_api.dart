// test_api.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  String apiKey = "AIzaSyAQ9fHtfFKaGi19CUEN-Q9Fp-xEIzLAhzA";
  
  final url = Uri.parse(
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey",
  );

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "What is 15 + 5 * 2?"}
          ]
        }
      ]
    }),
  );

  print("Status: ${response.statusCode}");
  print("Response: ${response.body}");
}