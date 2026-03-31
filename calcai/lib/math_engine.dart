import 'dart:math';
import 'package:expressions/expressions.dart';

String calculateLocally(String expression) {
  try {
    String mathExpr = expression
        .toLowerCase()
        .replaceAll('√', 'sqrt')
        .replaceAll('∛', 'cbrt')
        .replaceAll('square root of', 'sqrt')
        .replaceAll('square root', 'sqrt')
        .replaceAll('cube root of', 'cbrt')
        .replaceAll('cube root', 'cbrt')
        .replaceAll('root', 'sqrt')
        .replaceAll('to the power of', '^')
        .replaceAll('to the power', '^')
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
      String before = mathExpr;      // ← snapshot before
      mathExpr = mathExpr.replaceAllMapped(
        RegExp(r'(\d+(?:\.\d+)?)\^(\d+(?:\.\d+)?)'),
            (m) => _formatResult(
          pow(double.parse(m.group(1)!), double.parse(m.group(2)!)).toDouble(),
        ),
      );
      if (mathExpr == before) break; // ← no match made, exit to avoid freeze ✅
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

String _formatResult(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(10)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}
