import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../theme.dart';

/// Pengukur risiko melingkar — elemen utama layar hasil.
class RiskGauge extends StatelessWidget {
  final int score;
  final RiskLevel level;
  const RiskGauge({super.key, required this.score, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = riskColor(level);
    return SizedBox(
      width: 184,
      height: 184,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 184,
          height: 184,
          child: CircularProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            strokeWidth: 16,
            strokeCap: StrokeCap.round,
            backgroundColor: color.withValues(alpha: 0.14),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(riskIcon(level), color: color, size: 30),
          const SizedBox(height: 4),
          Text('$score', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w800, color: color, height: 1)),
          Text(riskHeadline(level),
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: C.ink.withValues(alpha: 0.7))),
        ]),
      ]),
    );
  }
}
