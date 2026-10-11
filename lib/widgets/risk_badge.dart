import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../theme.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final int? score;
  final bool large;
  const RiskBadge({super.key, required this.level, this.score, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = riskColor(level);
    final solid = level != RiskLevel.aman;
    final fg = solid ? Colors.white : color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 16 : 11, vertical: large ? 9 : 6),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: solid ? null : Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(riskIcon(level), color: fg, size: large ? 20 : 15),
        const SizedBox(width: 6),
        Text(
          score != null ? '${level.label} · $score' : level.label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: large ? 15 : 12.5),
        ),
      ]),
    );
  }
}
