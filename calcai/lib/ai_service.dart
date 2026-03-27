import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:math_expressions/math_expressions.dart';

class AIService {
  final String apiKey = "AIzaSyAQ9fHtfFKaGi19CUEN-Q9Fp-xEIzLAhzA";
  
  // Try local calculation first
   Future<String> getAnswer(String prompt) async {
    print("Processing: $prompt");
    
    // Step 1: Convert ALL word numbers to digits (generic)
    String convertedPrompt = _convertWordsToNumbers(prompt);
    print("Converted: $convertedPrompt");
    
    // Step 2: Try local calculation
    String localResult = _calculateLocally(convertedPrompt);
    if (localResult != "Error") {
      print("Local calculation success: $localResult");
      return localResult;
    }
    
    // Step 3: If local fails, use AI
    print("Local calculation failed, using AI...");
    return await _calculateWithAI(convertedPrompt);
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

  String _calculateLocally(String expression) {
    try {
      // Convert spoken words to math symbols
      String mathExpr = expression
          .toLowerCase()
          .replaceAll('plus', '+')
          .replaceAll('minus', '-')
          .replaceAll('times', '*')
          .replaceAll('multiplied by', '*')
          .replaceAll('divided by', '/')
          .replaceAll('x', '*')
          .replaceAll('÷', '/')
          .replaceAll(' ', '');
      
      // Remove any non-math characters
      mathExpr = mathExpr.replaceAll(RegExp(r'[^0-9+\-*/.]'), '');
      
      if (mathExpr.isEmpty) return "Error";
      
      // Check for division by zero
      if (mathExpr.contains('/0')) return "Cannot divide by zero";
      
      // Parse and evaluate
      Parser p = Parser();
      Expression exp = p.parse(mathExpr);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      
      // Format result
      if (result.isNaN || result.isInfinite) return "Error";
      
      if (result == result.roundToDouble()) {
        return result.toInt().toString();
      }
      
      return result.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      
    } catch (e) {
      print("Local calculation error: $e");
      return "Error";
    }
  }
  
  Future<String> _calculateWithAI(String prompt) async {
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
  }
}