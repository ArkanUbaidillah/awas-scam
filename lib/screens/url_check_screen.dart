import 'package:flutter/material.dart';
import '../models/url_check.dart';
import '../services/detector.dart';
import '../theme.dart';
import '../widgets/risk_badge.dart';

class UrlCheckScreen extends StatefulWidget {
  const UrlCheckScreen({super.key});
  @override
  State<UrlCheckScreen> createState() => _UrlCheckScreenState();
}

class _UrlCheckScreenState extends State<UrlCheckScreen> {
  final _controller = TextEditingController();
  UrlCheck? _result;

  void _check() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    setState(() => _result = SmishingDetector.analyzeUrl(t));
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: brandAppBar('Cek Tautan'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Bedah sebuah tautan tanpa membukanya — cepat dan tanpa internet.',
              style: TextStyle(color: C.muted)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: bgCard(context), borderRadius: BorderRadius.circular(16), boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ]),
            child: Column(children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'contoh: http://bri-hadiah.xyz/klaim',
                  hintStyle: const TextStyle(color: C.muted),
                  filled: true,
                  fillColor: inputFill(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _check(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                    onPressed: _check, icon: const Icon(Icons.travel_explore_rounded), label: const Text('Periksa tautan')),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          if (r != null) ...[
            Row(children: [
              RiskBadge(level: r.level, large: true),
              const SizedBox(width: 12),
              Expanded(child: Text(r.host, style: const TextStyle(fontFamily: 'monospace', fontSize: 13))),
            ]),
            const SizedBox(height: 16),
            ...r.findings.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(f.danger ? Icons.error_rounded : Icons.info_outline_rounded,
                        size: 18, color: f.danger ? C.danger : C.muted),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f.text, style: const TextStyle(height: 1.35, fontSize: 13.5))),
                  ]),
                )),
            const SizedBox(height: 16),
            const Text('Tautan tidak dibuka. Jika ragu, jangan klik.',
                style: TextStyle(color: C.muted, fontSize: 12.5)),
          ],
        ],
      ),
    );
  }
}
