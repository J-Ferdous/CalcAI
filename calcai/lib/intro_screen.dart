import 'package:flutter/material.dart';
import 'main.dart';
import 'calculator_logic.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {

  final CalculatorLogic _logic = CalculatorLogic();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _startIntro();
  }

  Future<void> _startIntro() async {
    _controller.forward();

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      await _logic.speak(
        "Hi! I am CalcAI, your AI voice calculator. "
        "Just speak something like fifteen plus five times two. "
        "And I will solve it instantly for you.",
      );
    } catch (e) {
      debugPrint("TTS Error: $e");
    }

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      _goToHome();
    }
  }

  Future<void> _goToHome() async {
    await _logic.initSpeech();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const VoiceCalculator(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    try {
      _logic.stop();
    } catch (e) {
      debugPrint("Stop error: $e");
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        // Gradient background (premium look)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFfff4fb),
              Color(0xFFf8e1ff),
              Color(0xFFf3d1ff),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Animated AI GIF
                  Hero(
                    tag: "ai_logo",
                    child: Image.asset(
                      'assets/ai.gif',
                      width: 260,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Name
                  Text(
                    "CalcAI",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFe2a9f1),
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Color(0xFFe2a9f1).withOpacity(0.6),
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  //  Subtitle
                  Text(
                    "Your Smart Voice Calculator",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Loading Indicator
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFFe2a9f1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
