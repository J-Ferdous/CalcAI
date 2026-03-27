import 'package:flutter/material.dart';
import 'main.dart';
import 'calculator_logic.dart';


class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {

  final CalculatorLogic _logic = CalculatorLogic();
  double _opacity = 0;

  @override
  void initState() {
    super.initState();

    // Fade animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1;
        });
      }
    });

    // Voice intro
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        _logic.speak(
          "Hi! I am Calcai, your AI voice calculator. "
          "Just speak something like fifteen plus five times two. "
          "And I will solve it instantly for you.",
        );
      } catch (e) {
        print("TTS Error: $e");
      }
    });

    // Auto navigate after intro
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        _goToHome();
      }
    });
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VoiceCalculator()),
    );
  }



  @override
  void dispose() {
    // Stop any ongoing speech
    try {
      _logic.stop(); // make sure this exists in CalculatorLogic
    } catch (e) {
      print("Stop error: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        duration: const Duration(seconds: 2),
        opacity: _opacity,
        child: Container(
          width: double.infinity,
          color: const Color(0xFFfff4fb),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/ai.gif',
                  width: 280,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                const Text(
                  "CalcAI",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Color(0xFFe2a9f1),
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: Color(0xFFe2a9f1),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}