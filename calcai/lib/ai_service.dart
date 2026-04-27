import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'basic-query.dart';
import 'math_engine.dart';
import 'dart:io';

class AIService {
  final String apiKey = "AIzaSyC4svzHQ5k2DJCl6WLZkiQ46LXPjEgu9QQ";

  Future<String> getAnswer(String prompt) async {
    print("Processing: $prompt");

    // Step 0: basic queries
    String? basicReply = handleBasicQueries(prompt);
    if (basicReply != null) return basicReply;

    // Step 1: check if math
    print("🔢 IS MATH: ${_isMathQuery(prompt)}");
    if (_isMathQuery(prompt)) {
      // ✅ Try local calculation FIRST on original prompt
      //    _calculateLocally does its own word→symbol conversion internally
      String localResult = _calculateLocally(prompt);

      if (localResult != "Error" && localResult != "Cannot divide by zero") {
        return localResult;
      }

      // ✅ Only if local fails, convert numbers then try again
      String convertedPrompt = _convertWordsToNumbers(prompt);
      print("Converted: $convertedPrompt");

      localResult = _calculateLocally(convertedPrompt);
      if (localResult != "Error") return localResult;

      // Check if there's actually something to send to AI
      if (!convertedPrompt.contains(RegExp(r'[0-9+\-*/^]'))) {
        return await _chatWithAI(prompt);
      }

      return await _solveMathWithAI(convertedPrompt);
    }

    return await _chatWithAI(prompt);
  }

  Future<String> _solveMathWithAI(String prompt) async {
    try {
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
                {
                  "text": "You are CalcAI, an AI voice calculator developed by Jannatul Ferdous. Your job is to solve math problems, including complex ones. Solve math problems and return ONLY the final answer (no explanation). If the question is unsolvable, undefined, or has no valid answer, reply: Cannot be determined. If it is not math, reply shortly and then tell the user to provide a math-related question. If the question is unclear or incomplete, ask the user to provide a clear math problem.: $prompt"
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.0,
            //"maxOutputTokens": 50,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      }

      return "Couldn't solve";
    } catch (e) {
      if (e is SocketException) {
        return "Check your internet connection and  try again";
      }
      return "Error";
    }
  }

  Future<String> _chatWithAI(String prompt) async {
    try {
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
                {
                "text": "You are CalcAI, an AI voice calculator developed by Jannatul Ferdous. Your job is to solve math problems, including complex ones. If it is a math question, return only the final answer. Do not explain anything. If it is not math, reply shortly and then tell the user to provide a math-related question. If unclear, politely guide the user to ask a math question.: $prompt"
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            //"maxOutputTokens": 100,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["candidates"][0]["content"]["parts"][0]["text"];
      }
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      final random = Random();
      List<String> responses = [
        "Sorry, I didn't understand. Please try again.",
        "Didn't get that. Try again.",
        "Could you repeat that?",
        "I couldn't understand. Ask again.",
        "Hmm, I missed that. Try once more."
      ];

      return responses[random.nextInt(responses.length)];

    } catch (e) {
      if (e is SocketException) {
        return "Check your internet connection and  try again";
      }
      return "Error";
    }
  }


  bool _isMathQuery(String input) {
    final mathKeywords = [
      'plus', 'minus', 'times', 'into', 'divided',
      'add', 'subtract', 'multiply', 'divide',
      'square root', 'cube root', 'power', 'root',
      '+', '-', '*', '/', '^',
      '√', '∛',          // ← add these
    ];

    input = input.toLowerCase();

    bool hasNumber = RegExp(r'\d').hasMatch(input);
    bool hasMathWord = mathKeywords.any((word) => input.contains(word));

    // ← also check for √ and ∛ symbols directly
    bool hasMathSymbol = RegExp(r'[+\-*/^√∛]').hasMatch(input);

    return hasMathWord || (hasNumber && hasMathSymbol);
  }

  String _convertWordsToNumbers(String text) {
    String result = text.toLowerCase();
    
    // Step 1: Replace individual number words (1-19)
    Map<String, int> smallNumbers = {
      'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
      'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9,
      'ten': 10, 'eleven': 11, 'twelve': 12, 'thirteen': 13,
      'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17,
      'eighteen': 18, 'nineteen': 19,
    };
    
    // Step 2: Replace tens (20-90)
    Map<String, int> tens = {
      'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50,
      'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90,
    };
    
    // Step 3: Scale words
    Map<String, int> scales = {
      'hundred': 100,
      'thousand': 1000,
      'million': 1000000,
      'billion': 1000000000,
      'trillion': 1000000000000,
    };
    
    // First, handle compound numbers like "twenty five"
    for (var tensWord in tens.keys) {
      for (var smallWord in smallNumbers.keys) {
        String pattern = '$tensWord $smallWord';
        if (result.contains(pattern)) {
          int value = tens[tensWord]! + smallNumbers[smallWord]!;
          result = result.replaceAll(pattern, value.toString());
        }
      }
    }
    
    // Replace "twenty", "thirty", etc. alone
    tens.forEach((word, value) {
      result = result.replaceAll(word, value.toString());
    });
    
    // Replace small numbers
    smallNumbers.forEach((word, value) {
      result = result.replaceAll(word, value.toString());
    });
    
    // Handle scale words with preceding numbers (e.g., "5 hundred", "2 thousand")
    for (var scale in scales.keys) {
      // Match: number + scale (e.g., "5 hundred", "123 thousand")
      RegExp pattern = RegExp(r'(\d+)\s+' + scale);
      result = result.replaceAllMapped(pattern, (match) {
        int number = int.parse(match.group(1)!);
        int multiplier = scales[scale]!;
        return (number * multiplier).toString();
      });
      
      // Handle scale alone (e.g., "hundred" = 100)
      result = result.replaceAll(scale, scales[scale].toString());
    }
    
    // Handle complex combinations like "five hundred thousand"
    // This handles cases where multiple scales combine
    RegExp complexPattern = RegExp(r'(\d+)\s+(\d+)\s+(\d+)');
    while (complexPattern.hasMatch(result)) {
      result = result.replaceAllMapped(complexPattern, (match) {
        int a = int.parse(match.group(1)!);
        int b = int.parse(match.group(2)!);
        int c = int.parse(match.group(3)!);
        return (a + b + c).toString();
      });
    }
    
    // Handle multiple scale words like "hundred thousand"
    List<String> scalesList = ['hundred', 'thousand', 'million', 'billion', 'trillion'];
    for (int i = 0; i < scalesList.length - 1; i++) {
      String pattern = '${scales[scalesList[i]]} ${scales[scalesList[i + 1]]}';
      if (result.contains(pattern)) {
        int value = scales[scalesList[i]]! * scales[scalesList[i + 1]]!;
        result = result.replaceAll(pattern, value.toString());
      }
    }
    
    return result;
  }

  String _calculateLocally(String expression) => calculateLocally(expression);


/*  Future<String> _calculateWithAI(String prompt) async {
    try {
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
                {
                  "text": "Convert this to a math expression with symbols (+, -, *, /). Return ONLY the expression: $prompt"
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.0,
            "maxOutputTokens": 50,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String mathExpr = data["candidates"][0]["content"]["parts"][0]["text"];
        
        // Clean the expression
        mathExpr = mathExpr
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll(' ', '');
        
        // Calculate the parsed expression locally
        return _calculateLocally(mathExpr);
      }
      
      return "Could not understand";
    } catch (e) {
      return "Error: $e";
    }
  }*/
}