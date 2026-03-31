import 'dart:math';
import 'package:expressions/expressions.dart';

// Paste your _calculateLocally here (as a top-level function for testing)
String calculateLocally(String expression) {
  try {
    String mathExpr = expression
        .toLowerCase()
        .replaceAll('square root of', 'sqrt')
        .replaceAll('square root', 'sqrt')
        .replaceAll('cube root of', 'cbrt')
        .replaceAll('cube root', 'cbrt')
        .replaceAll('to the power of', '^')
        .replaceAll('raised to', '^')
        .replaceAll('multiplied by', '*')
        .replaceAll('divided by', '/')
        .replaceAll('plus', '+')
        .replaceAll('minus', '-')
        .replaceAll('times', '*')
        .replaceAll('into', '*')
        .replaceAll('power', '^')
        .replaceAll('x', '*')
        .replaceAll('÷', '/')
        .replaceAll(' ', '');

    print("  A: $mathExpr");
    mathExpr = mathExpr.replaceAll(RegExp(r'[^0-9+\-*/.^a-z()]'), '');
    print("  B: $mathExpr");

    if (mathExpr.isEmpty) return "Error";
    if (mathExpr.contains('/0')) return "Cannot divide by zero";

    mathExpr = mathExpr.replaceAllMapped(
      RegExp(r'cbrt\(?(\d+(?:\.\d+)?)\)?'),
          (m) => _formatResult(pow(double.parse(m.group(1)!), 1 / 3).toDouble()),
    );
    print("  C: $mathExpr");

    mathExpr = mathExpr.replaceAllMapped(
      RegExp(r'sqrt\(?(\d+(?:\.\d+)?)\)?'),
          (m) => _formatResult(sqrt(double.parse(m.group(1)!))),
    );
    print("  D: $mathExpr");

    while (mathExpr.contains('^')) {
      mathExpr = mathExpr.replaceAllMapped(
        RegExp(r'(\d+(?:\.\d+)?)\^(\d+(?:\.\d+)?)'),
            (m) => _formatResult(
          pow(double.parse(m.group(1)!), double.parse(m.group(2)!)).toDouble(),
        ),
      );
    }
    print("  E: $mathExpr");

    final evaluator = const ExpressionEvaluator();
    final parsed = Expression.parse(mathExpr);
    dynamic result = evaluator.eval(parsed, {});
    print("  F: $result");

    double finalResult = (result as num).toDouble();
    if (finalResult.isNaN || finalResult.isInfinite) return "Error";
    return _formatResult(finalResult);

  } catch (e) {
    print("  💥 CRASH: $e");
    return "Error";
  }
}

// ✅ Shared formatter — avoids repeating the rounding logic everywhere
String _formatResult(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(10)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}
// ─── Test runner ────────────────────────────────────────────────────────────

void runTest(String label, String input, String expected) {
  String got = calculateLocally(input);
  bool pass = got == expected;
  print('${pass ? "✅" : "❌"} $label');
  if (!pass) {
    print('     input   : $input');
    print('     expected: $expected');
    print('     got     : $got');
  }
}

void main() {
  print('\n════════ _calculateLocally Tests ════════\n');

  runTest('sqrt symbol sqrt()',        'sqrt(144)',           '12');
  runTest('square root keyword',       'square root 81',     '9');
  runTest('square root of keyword',    'square root of 64',  '8');
  runTest('sqrt decimal result',       'sqrt(2)',             '1.4142135624');

  print('\n═════════════════════════════════════════\n');
}