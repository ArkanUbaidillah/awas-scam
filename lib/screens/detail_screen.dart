import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../services/detector.dart';
import '../services/history_store.dart';
import '../theme.dart';
import '../widgets/reason_tile.dart';
import '../widgets/risk_gauge.dart';

class DetailScreen extends StatefulWidget {
  final Detection detection;
  const DetailScreen({super.key, required this.detection});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _store = HistoryStore();
  bool? _feedback;

  @override
  void initState() {
    super.initState();
    _feedback = widget.detection.feedback;
  }

  Future<void> _setFeedback(bool value) async {
    setState(() => _feedback = value);
    await _store.setFeedback(widget.detection, value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(value ? 'Ditandai: benar penipuan. Terima kasih.' : 'Ditandai: salah tandai. Terima kasih.'),
      ));
    }
  }

  Widget _scorePill(String label, int value, Color color) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Column(children: [
            Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: C.muted)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final d = widget.detection;
    final color = riskColor(d.level);
    return Scaffold(
      appBar: brandAppBar('Hasil pemeriksaan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
        children: [
          Center(child: RiskGauge(score: d.score, level: d.level)),
          const SizedBox(height: 22),
          Row(children: [
            _scorePill('Pola', d.ruleScore, C.brand),
            _scorePill('AI', d.mlScore, C.gold),
            _scorePill('Gabungan', d.score, color),
          ]),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(riskIcon(d.level), color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(riskHeadline(d.level), style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 4),
                  Text(SmishingDetector.advice(d.level), style: const TextStyle(height: 1.4, fontSize: 13.5)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SelectableText(d.message, style: const TextStyle(height: 1.45)),
            ),
          ),
          const SizedBox(height: 20),
          if (d.reasons.isNotEmpty) ...[
            Text('Kenapa ditandai (${d.reasons.length})',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ...d.reasons.map((r) => ReasonTile(reason: r)),
            const SizedBox(height: 10),
          ],
          const Divider(height: 28),
          const Text('Menurutmu hasil ini benar?', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _fbButton(true, Icons.thumb_up_alt_rounded, 'Benar penipuan', C.danger)),
            const SizedBox(width: 10),
            Expanded(child: _fbButton(false, Icons.thumb_down_alt_rounded, 'Salah tandai', C.safe)),
          ]),
          const SizedBox(height: 14),
          const Text('Hasil ini bantuan deteksi, bukan kepastian. Umpan balikmu membantu memperbaiki model.',
              style: TextStyle(color: C.muted, fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _fbButton(bool value, IconData icon, String label, Color color) {
    final active = _feedback == value;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? color : Theme.of(context).colorScheme.onSurface,
        backgroundColor: active ? color.withValues(alpha: 0.1) : null,
        side: BorderSide(color: active ? color : Colors.black26),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => _setFeedback(value),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
