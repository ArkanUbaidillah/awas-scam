import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../services/history_store.dart';
import '../services/stats.dart';
import '../theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Stats? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HistoryStore().load();
    if (mounted) setState(() => _stats = Stats.from(items));
  }

  Widget _summary(String label, String value, Color color, IconData icon) => Expanded(
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: bgCard(context), borderRadius: BorderRadius.circular(16), boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: C.muted)),
          ]),
        ),
      );

  Widget _bar(String label, int value, int max, Color color) {
    final frac = max == 0 ? 0.0 : value / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 118, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(children: [
              Container(height: 22, color: Colors.black.withValues(alpha: 0.06)),
              FractionallySizedBox(widthFactor: frac.clamp(0.0, 1.0), child: Container(height: 22, color: color)),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 26, child: Text('$value', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _stats;
    return Scaffold(
      appBar: brandAppBar('Statistik', actions: [
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Colors.white)),
      ]),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : s.total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.bar_chart_rounded, size: 56, color: C.muted.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text('Belum ada data', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Periksa beberapa pesan dulu di tab Periksa.',
                          textAlign: TextAlign.center, style: TextStyle(color: C.muted)),
                    ]),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(children: [
                      _summary('Diperiksa', '${s.total}', C.brand, Icons.fact_check_outlined),
                      _summary('Ditandai', '${s.flagged}', C.warn, Icons.warning_amber_rounded),
                      _summary('Bahaya', '${s.byLevel[RiskLevel.bahaya] ?? 0}', C.danger, Icons.gpp_bad_outlined),
                    ]),
                    const SizedBox(height: 22),
                    const Text('Tingkat risiko', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 8),
                    _bar('Aman', s.byLevel[RiskLevel.aman] ?? 0, s.total, C.safe),
                    _bar('Waspada', s.byLevel[RiskLevel.waspada] ?? 0, s.total, C.warn),
                    _bar('Bahaya', s.byLevel[RiskLevel.bahaya] ?? 0, s.total, C.danger),
                    if (s.topCategories.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      const Text('Modus paling sering', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      ...s.topCategories.map((e) => _bar(
                          Stats.categoryLabel[e.key] ?? e.key, e.value, s.topCategories.first.value, C.brand)),
                    ],
                    const SizedBox(height: 22),
                    const Text('Ditandai 7 hari terakhir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 12),
                    _WeekChart(days: s.last7Days),
                    if (s.confirmed + s.falsePositive > 0) ...[
                      const SizedBox(height: 22),
                      const Text('Umpan balikmu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      Text('Benar penipuan: ${s.confirmed}   ·   Salah tandai: ${s.falsePositive}',
                          style: const TextStyle(color: C.muted)),
                    ],
                  ],
                ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List<int> days;
  const _WeekChart({required this.days});
  @override
  Widget build(BuildContext context) {
    final max = days.fold<int>(1, (p, e) => e > p ? e : p);
    const labels = ['6h', '5h', '4h', '3h', '2h', 'Kmrn', 'Ini'];
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final barH = 96.0 * (days[i] / max);
          return Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
              Text('${days[i]}', style: const TextStyle(fontSize: 11, color: C.muted)),
              const SizedBox(height: 3),
              Container(
                height: barH < 5 ? 5 : barH,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [C.warn, Color(0xFFF0B45E)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                ),
              ),
              const SizedBox(height: 5),
              Text(labels[i], style: const TextStyle(fontSize: 10, color: C.muted)),
            ]),
          );
        }),
      ),
    );
  }
}
