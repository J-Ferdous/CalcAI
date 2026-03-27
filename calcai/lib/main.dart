import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'calculator_logic.dart';
import 'ai_service.dart';
import 'intro_screen.dart';

void main() {
  runApp(const VoiceCalculatorApp());
}

class VoiceCalculatorApp extends StatelessWidget {
  const VoiceCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const IntroScreen(),
    );
  }
}

class VoiceCalculator extends StatefulWidget {
  const VoiceCalculator({super.key});

  @override
  _VoiceCalculatorState createState() => _VoiceCalculatorState();
}

class _VoiceCalculatorState extends State<VoiceCalculator> {
  final CalculatorLogic _logic = CalculatorLogic();
  bool _isListening = false;
  String _spokenText = "Tap the mic and say something like\n'15 plus 5 times 2'";
  String _result = "0";

  void _listen() async {
    if (!_isListening) {
      bool available = await _logic.initSpeech();
      if (available) {
        setState(() => _isListening = true);
        _logic.speech.listen(
          onResult: (val) {
            setState(() {
              _spokenText = val.recognizedWords;
              if (val.finalResult) {
                _isListening = false;
                _processCalculation(_spokenText);
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _logic.speech.stop();
    }
  }

  final AIService _ai = AIService();

void _processCalculation(String input) async {
  String res = await _ai.getAnswer(input);

  setState(() {
    _result = res;
  });

  _logic.speak("The answer is $res");
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298), Color(0xFF2193b0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "VOICE CALCULATOR",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              
              // Spoken Text Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  _spokenText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              
              const SizedBox(height: 50),

              // Result Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text("RESULT", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2))],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Animated Microphone Button
              AvatarGlow(
                animate: _isListening,
                glowColor: Colors.cyanAccent,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: GestureDetector(
                  onTap: _listen,
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening 
                          ? [Colors.redAccent, Colors.orangeAccent] 
                          : [Colors.cyanAccent, Colors.blueAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Colors.cyan).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isListening ? "Listening..." : "Tap to Speak",
                style: TextStyle(
                  color: _isListening ? Colors.redAccent : Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}