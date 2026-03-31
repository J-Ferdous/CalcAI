import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calculator_logic.dart';
import 'ai_service.dart';
import 'intro_screen.dart';
import 'palette.dart';
import 'widgets.dart';
import 'wave.dart';

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
  State<VoiceCalculator> createState() => _VoiceCalculatorState();
}

class _VoiceCalculatorState extends State<VoiceCalculator>
    with TickerProviderStateMixin {
  final CalculatorLogic _logic = CalculatorLogic();
  final AIService _ai = AIService();

  bool _isListening = false;
  String _spokenText = 'Tap the mic and say something like "15 plus 5 times 2"';
  String _result = '—';
  String _resultSub = 'Awaiting your voice';

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  late AnimationController _barCtrl;

  @override
  void initState() {

    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      _floatCtrl.forward(from: 0);
      _barCtrl.repeat(reverse: true);

      setState(() {
        _isListening = true;
        _spokenText = 'Speak now…';
        _result = '—';
        _resultSub = 'Processing…';
      });

      Future(() async {
        bool available = await _logic.initSpeech();

        if (available) {
          _logic.speech.listen(
            onResult: (val) {
              setState(() {
                _spokenText = val.recognizedWords;

                if (val.finalResult) {
                  _isListening = false;
                  _barCtrl.stop();
                  _processCalculation(_spokenText);
                }
              });
            },
          );
        } else {
          setState(() {
            _isListening = false;
            _barCtrl.stop();
          });
        }
      });

    } else {
      setState(() => _isListening = false);
      _barCtrl.stop();
      _logic.speech.stop();
    }
  }

  bool _isMathQuery(String input) {
    final mathKeywords = [
      'plus', 'minus', 'times', 'into', 'divided',
      'add', 'subtract', 'multiply', 'divide',
      'square root', 'cube root', 'power','root',
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

  void _processCalculation(String input) async {
    final res = await _ai.getAnswer(input);
    setState(() {
      _result = res;
      _resultSub = input;
    });
    if (_isMathQuery(input)) {
      _logic.speak('The answer is $res');
    } else {
      _logic.speak(res);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        buildTopBar(),
                        const SizedBox(height: 16),
                        _buildRobotStage(),
                        const SizedBox(height: 16),
                        _buildGlassCard(),
                        const SizedBox(height: 30),
                        _buildMicButton(),
                        const SizedBox(height: 8),
                        _buildTapLabel(),
                        const SizedBox(height: 30),
                        bottomLabel()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotStage() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatAnim,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              0,
              (_isListening ? -6 : 0) + _floatAnim.value,
            ),
            child: child,
          ),
            child: Center(
              child: Image.asset(
                _isListening ? 'assets/ai-listening.gif' : 'assets/ai-speaking.gif',
                width: 300,
                //fit: BoxFit.contain,
              ),
            ),
          ),

        const SizedBox(height: 10),
        // Greeting row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 10),
        // Sound bars
        /*Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(6, (i) {
            const delays = [0.0, 0.15, 0.05, 0.25, 0.10, 0.30];
            return _SoundBar(active: _isListening, delay: delays[i]);
          }),
        ),*/
      ],
    );
  }

  Widget _buildGlassCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: lavender.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sLabel('YOUR QUERY', textMuted),
                const SizedBox(height: 8),

                SizedBox(
                  height: 38,
                  child: SingleChildScrollView(
                    child: Text(
                      _spokenText,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textBody,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                PastelDivider(),
                const SizedBox(height: 14),

                sLabel('RESULT', pink),
                const SizedBox(height: 10),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isListening
                      ? buildWaveform()
                      : buildResultText(_result),
                ),

                const SizedBox(height: 6),

                Text(
                  _resultSub,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _listen,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 🌊 Ripple Effect (reduced + smoother)
              if (_isListening)
                Container(
                  width: 140 * _pulseAnimation.value,
                  height: 140 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA594F9).withOpacity(0.10),
                  ),
                ),

              if (_isListening)
                Container(
                  width: 170 * _pulseAnimation.value,
                  height: 170 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5EFFF).withOpacity(0.25),
                  ),
                ),

              // ✨ Outer Glow Ring (more subtle now)
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF5EFFF).withOpacity(
                          _isListening ? 0.30 : 0.18), // reacts to state
                      Colors.transparent,
                    ],
                    radius: 0.85,
                  ),
                ),
              ),

              // 💎 Main Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),

                // smoother size jump
                width: _isListening ? 95 : 90,
                height: _isListening ? 95 : 90,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  // 🎨 Slightly richer gradient when listening
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [
                      const Color(0xFF9F8AFB), // deeper purple
                      const Color(0xFFEADFFF), // soft highlight
                    ]
                        : [
                      const Color(0xFFA594F9),
                      const Color(0xFFF5EFFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  // ✨ Add glow only when listening
                  boxShadow: _isListening
                      ? [
                    BoxShadow(
                      color: const Color(0xFFA594F9).withOpacity(0.45),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                      : [],
                ),

                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _isListening ? 70 : 75,
                    height: _isListening ? 70 : 75,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(
                          _isListening ? 0.20 : 0.15), // slightly brighter
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),

                    child: Icon(
                      _isListening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTapLabel() => Text(
    _isListening ? 'Listening…' : 'Tap to speak',
    style: GoogleFonts.quicksand(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: _isListening ? pink : textMuted,
      letterSpacing: 0.2,
    ),
  );


}






