import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../theme.dart';

class ReasonTile extends StatelessWidget {
  final Reason reason;
  const ReasonTile({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final isAi = reason.category == 'ai';
    final c = isAi ? C.gold : C.danger;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(isAi ? Icons.auto_awesome : Icons.flag_rounded, size: 15, color: c),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(reason.text, style: const TextStyle(height: 1.35, fontSize: 13.5))),
      ]),
    );
  }
}
