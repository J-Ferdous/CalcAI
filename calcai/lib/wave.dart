import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class SiriWave extends StatefulWidget {
  const SiriWave();

  @override
  State<SiriWave> createState() => _SiriWaveState();
}

class _SiriWaveState extends State<SiriWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(_controller.value),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;

  _WavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final width = size.width;

    final phase = t * 2 * pi;

    // 🌊 Smooth breathing amplitude
    final amplitude = 14 + 6 * sin(t * 2 * pi);

    // 🌈 Gradient (premium look)
    final gradient = LinearGradient(
      colors: [
        const Color(0xFFC084FC),
        const Color(0xFFA594F9),
        const Color(0xFFF9A8D4),
      ],
    );

    Paint createPaint(double opacity, double strokeWidth) {
      return Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, width, size.height),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8) // ✨ glow
        ..color = Colors.white.withOpacity(opacity);
    }

    final paintBack = createPaint(0.25, 2);
    final paintFront = createPaint(0.8, 3);

    final bridgePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, width, size.height),
      )
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = Colors.white.withOpacity(0.4);

    final path1 = Path();
    final path2 = Path();

    List<Offset> points1 = [];
    List<Offset> points2 = [];

    for (double x = 0; x <= width; x += 3) {
      double normX = x / width;

      // 🧬 DNA strands (opposite waves)
      double y1 = midY + amplitude * sin((normX * 2 * pi) + phase);
      double y2 = midY + amplitude * sin((normX * 2 * pi) + phase + pi);

      final p1 = Offset(x, y1);
      final p2 = Offset(x, y2);

      points1.add(p1);
      points2.add(p2);

      if (x == 0) {
        path1.moveTo(p1.dx, p1.dy);
        path2.moveTo(p2.dx, p2.dy);
      } else {
        path1.lineTo(p1.dx, p1.dy);
        path2.lineTo(p2.dx, p2.dy);
      }
    }

    // 🧬 Bridges (DNA links)
    for (int i = 0; i < points1.length; i += 6) {
      canvas.drawLine(points1[i], points2[i], bridgePaint);
    }

    // 🎵 Draw strands (layered glow effect)
    canvas.drawPath(path1, paintBack);
    canvas.drawPath(path2, paintBack);

    canvas.drawPath(path1, paintFront);
    canvas.drawPath(path2, paintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaveBar extends StatefulWidget {
  final bool isActive;
  final double delay;

  const WaveBar({required this.isActive, required this.delay});

  @override
  State<WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<WaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 5, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _sync();
  }

  @override
  void didUpdateWidget(covariant WaveBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.isActive) {
      Future.delayed(Duration(milliseconds: (widget.delay * 200).toInt()), () {
        if (mounted) _controller.repeat(reverse: true);
      });
    } else {
      _controller.animateTo(0.1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: 4,
          height: _animation.value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFC084FC),
                const Color(0xFFF472B6),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        );
      },
    );
  }
}

class PastelDivider extends StatelessWidget {
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

/*class _SoundBar extends StatefulWidget {
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
}*/

