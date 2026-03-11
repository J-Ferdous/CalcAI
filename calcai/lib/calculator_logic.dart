import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorLogic {
  SpeechToText speech = SpeechToText();
  FlutterTts tts = FlutterTts();

  Future<bool> initSpeech() async {
    return await speech.initialize();
  }

  void speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  String convertWordsToMath(String input) {
    input = input.toLowerCase();

    // Basic Operations
    input = input.replaceAll("plus", "+");
    input = input.replaceAll("minus", "-");
    input = input.replaceAll("times", "*");
    input = input.replaceAll("multiply", "*");
    input = input.replaceAll("into", "*");
    input = input.replaceAll("divide", "/");
    input = input.replaceAll("divided by", "/");
    
    // Advanced Operations
    input = input.replaceAll("to the power of", "^");
    input = input.replaceAll("squared", "^2");
    input = input.replaceAll("cube", "^3");
    input = input.replaceAll("square root of", "sqrt");
    input = input.replaceAll("percent", "/100");
    input = input.replaceAll("mod", "%");

    // Handling "sqrt 16" to "sqrt(16)"
    if (input.contains("sqrt")) {
      RegExp reg = RegExp(r'sqrt (\d+)');
      input = input.replaceAllMapped(reg, (match) => "sqrt(${match.group(1)})");
    }

    return input;
  }

  String calculate(String voiceInput) {
    try {
      String expression = convertWordsToMath(voiceInput);
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Remove decimal if it's a whole number
      String finalResult = eval % 1 == 0 ? eval.toInt().toString() : eval.toStringAsFixed(2);
      return finalResult;
    } catch (e) {
      return "Error";
    }
  }
}