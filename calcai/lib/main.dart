import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
// ─────────────────────────────────────────────
//  CalcAI — Redesigned Voice Calculator UI
//  Theme: Dark glass · Conic gradient ring
//        Animated sound bars · Syne + DM Sans
// ─────────────────────────────────────────────



// ─────────────────────────────────────────────
//  CalcAI — Pastel Robot Theme
//  Palette extracted from the robot character:
//    Lavender  #C084FC  (body / primary)
//    Soft Pink #F472B6  (cheeks / accent)
//    Blush     #F9A8D4  (highlight)
//    BG        #FDF5FF  (off-white lavender)
//    Deep Plum #7C3AED  (text / brand)
// ─────────────────────────────────────────────

class VoiceCalculator extends StatefulWidget {
  const VoiceCalculator({super.key});
  @override
  State<VoiceCalculator> createState() => _VoiceCalculatorState();
}

class _VoiceCalculatorState extends State<VoiceCalculator>
    with TickerProviderStateMixin {
  // ── Services (unchanged) ────────────────────
  final CalculatorLogic _logic = CalculatorLogic();
  final AIService _ai = AIService();

  bool _isListening = false;
  String _spokenText = 'Tap the mic and say something like "15 plus 5 times 2"';
  String _result = '—';
  String _resultSub = 'Awaiting your voice';

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  late AnimationController _barCtrl;

  // ── Pastel palette ──────────────────────────
  static const _bg        = Color(0xFFfff4fb);
  static const _lavender  = Color(0xFFC084FC);
  static const _pink      = Color(0xFFF472B6);
  static const _blush     = Color(0xFFF9A8D4);
  static const _deepPlum  = Color(0xFF7C3AED);
  static const _textBody  = Color(0xFF8B6DAA);
  static const _textMuted = Color(0xFFC4A8DC);
  static const _cardBg    = Color(0xD0FFFFFF);
  static const _cardBorder = Color(0x4DC4A0E6);

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
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _logic.initSpeech();
      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = 'Speak now…';
          _result = '—';
          _resultSub = 'Processing…';
        });
        _barCtrl.repeat(reverse: true);
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
      }
    } else {
      setState(() => _isListening = false);
      _barCtrl.stop();
      _logic.speech.stop();
    }
  }

  void _processCalculation(String input) async {
    final res = await _ai.getAnswer(input);
    setState(() {
      _result = res;
      _resultSub = input;
    });
    _logic.speak('The answer is $res');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
                        _buildTopBar(),
                        const SizedBox(height: 16),
                        _buildRobotStage(),
                        const SizedBox(height: 16),
                        _buildGlassCard(),
                        const SizedBox(height: 30),
                        //_buildChips(),
                        //const Spacer(),
                        _buildMicButton(),
                        const SizedBox(height: 8),
                        _buildTapLabel(),
                        const SizedBox(height: 20),
                        //_buildBottomNav(),
                        //const SizedBox(height: 24),
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

  // ─────────────────────────────────────────────
  //  TOP BAR
  // ─────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [_lavender, _pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _lavender.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'CalcAI',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _deepPlum,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ROBOT STAGE
  // ─────────────────────────────────────────────
  Widget _buildRobotStage() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatAnim,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _isListening ? _floatAnim.value * 0.6 : _floatAnim.value),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(6, (i) {
            const delays = [0.0, 0.15, 0.05, 0.25, 0.10, 0.30];
            return _SoundBar(active: _isListening, delay: delays[i]);
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  GLASS CARD
  // ─────────────────────────────────────────────
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
              color: _cardBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _lavender.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sLabel('YOUR QUERY', _textMuted),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: SingleChildScrollView(
                    child: Text(
                      _spokenText,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _textBody,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _PastelDivider(),
                const SizedBox(height: 14),
                _sLabel('RESULT', _pink),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [_deepPlum, _pink, _blush],
                      stops: [0.0, 0.6, 1.0],
                    ).createShader(r),
                    child: Text(
                      _result,
                      style: GoogleFonts.nunito(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _resultSub,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sLabel(String t, Color c) => Text(
    t,
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: c,
      fontFamily: 'Quicksand',
    ),
  );

  // ─────────────────────────────────────────────
  //  MIC BUTTON
  // ─────────────────────────────────────────────
  Widget _buildMicButton() {
    return AvatarGlow(
      animate: _isListening,
      glowColor: _isListening ? _pink : _lavender,
      duration: const Duration(milliseconds: 1400),
      child: GestureDetector(
        onTap: _listen,
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: _isListening
                  ? [_pink, const Color(0xFFFB7185)]
                  : [_lavender, _pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isListening ? _pink : _lavender).withOpacity(0.45),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            _isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildTapLabel() => Text(
    _isListening ? 'Listening…' : 'Tap to speak',
    style: GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _isListening ? _pink : _textMuted,
      letterSpacing: 0.2,
    ),
  );

  // ─────────────────────────────────────────────
  //  BOTTOM NAV
  // ─────────────────────────────────────────────
}

// ─────────────────────────────────────────────
//  SUB-WIDGETS
// ─────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double? top, bottom, left, right;
  const _Blob({required this.color, required this.size, this.top, this.bottom, this.left, this.right});

  @override
  Widget build(BuildContext context) => Positioned(
    top: top, bottom: bottom, left: left, right: right,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    ),
  );
}

class _PastelDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        Colors.transparent,
        const Color(0xFFC4A0E6).withOpacity(0.35),
        Colors.transparent,
      ]),
    ),
  );
}

class _SoundBar extends StatefulWidget {
  final bool active;
  final double delay;
  const _SoundBar({required this.active, required this.delay});
  @override
  State<_SoundBar> createState() => _SoundBarState();
}

class _SoundBarState extends State<_SoundBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 500 + (widget.delay * 400).toInt()));
    _anim = Tween<double>(begin: 5, end: 18).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _sync();
  }

  @override
  void didUpdateWidget(_SoundBar old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.active) {
      Future.delayed(Duration(milliseconds: (widget.delay * 300).toInt()), () {
        if (mounted) _ctrl.repeat(reverse: true);
      });
    } else {
      _ctrl.animateTo(0, duration: const Duration(milliseconds: 250));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      width: 5,
      height: _anim.value,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: widget.active
              ? [const Color(0xFFC084FC), const Color(0xFFF9A8D4)]
              : [const Color(0xFFC084FC).withOpacity(0.3), const Color(0xFFF9A8D4).withOpacity(0.3)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    ),
  );
}