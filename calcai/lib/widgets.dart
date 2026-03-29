import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wave.dart';
import 'palette.dart';


Widget buildTopBar() {
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
                  colors: [lavender, pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: lavender.withOpacity(0.4),
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
                color: deepPlum,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildWaveform() {
  return SizedBox(
    key: const ValueKey("wave"),
    height: 60,
    width: double.infinity,
    child: const SiriWave(),
  );
}

Widget sLabel(String t, Color c) => Text(
  t,
  style: TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: c,
    fontFamily: 'Quicksand',
  ),
);

Widget buildResultText(String _result) {
  return FittedBox(
    key: const ValueKey("result"),
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [ Color(0xFFC9BEFF), Color(0xFF9F8AFB),Color(0xFFD78FEE)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(bounds),
      child: Text(
        _result,
        style: GoogleFonts.nunito(
          fontSize: 52,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -2,
        ),
      ),
    ),
  );
}
