import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'math_engine.dart';

class CalculatorLogic {
  SpeechToText speech = SpeechToText();
  FlutterTts tts = FlutterTts();

  Future<bool> initSpeech() async => await speech.initialize();

  void speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.speak(text);
  }

  void stop() async => await tts.stop();

  // ✅ Now just delegates to the shared engine
  String calculate(String voiceInput) => calculateLocally(voiceInput);
}
