import 'package:flutter/material.dart';
import '../models/detection.dart';
import '../services/detector.dart';
import '../services/history_store.dart';
import '../services/sms_service.dart';
import '../theme.dart';
import '../widgets/risk_badge.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _history = HistoryStore();
  final _sms = SmsService();
  List<Detection> _items = [];
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _history.load();
    if (mounted) setState(() => _items = items);
  }

  Future<void> _open(Detection d) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(detection: d)));
    await _load();
  }

  Future<void> _check() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final result = SmishingDetector.analyze(text);
    await _history.add(result);
    _controller.clear();
    await _load();
    if (mounted) _open(result);
  }

  Future<void> _scanSms() async {
    if (!_sms.supported) {
      _snack('Membaca SMS hanya tersedia di Android. Tempel pesan secara manual.');
      return;
    }
    if (!await _sms.requestPermission()) {
      _snack('Izin membaca SMS ditolak.');
      return;
    }
    setState(() => _scanning = true);
    try {
      final bodies = await _sms.readInbox(limit: 50);
      var flagged = 0;
      for (final body in bodies) {
        final d = SmishingDetector.analyze(body);
        if (d.level != RiskLevel.aman) {
          await _history.add(d);
          flagged++;
        }
      }
      await _load();
      _snack('Memindai ${bodies.length} SMS, $flagged ditandai mencurigakan.');
    } catch (e) {
      _snack('Gagal membaca SMS: $e');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _header(),
          Expanded(
            child: _items.isEmpty
                ? _empty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: _items.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 10, left: 4),
                          child: Text('Riwayat', style: TextStyle(fontWeight: FontWeight.w700)),
                        );
                      }
                      return _tile(_items[i - 1]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: const BoxDecoration(
        gradient: C.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 12, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.shield_rounded, color: C.gold, size: 26),
              const SizedBox(width: 10),
              const Text('Awas Scam',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
              const Spacer(),
              IconButton(
                tooltip: 'Pengaturan',
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              if (_items.isNotEmpty)
                IconButton(
                  tooltip: 'Hapus riwayat',
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                  onPressed: () async {
                    await _history.clear();
                    await _load();
                  },
                ),
            ]),
            const SizedBox(height: 2),
            Text('Tempel pesan mencurigakan, periksa dalam sekejap.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13.5)),
            const SizedBox(height: 16),
            _inputCard(),
          ]),
        ),
      ),
    );
  }

  Widget _inputCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCard(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 6,
          style: const TextStyle(height: 1.4),
          decoration: InputDecoration(
            hintText: 'Contoh: Selamat! Anda memenangkan undian Rp175 juta...',
            hintStyle: const TextStyle(color: C.muted),
            filled: true,
            fillColor: inputFill(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _check,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Periksa pesan'),
            ),
          ),
          if (_sms.supported) ...[
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: C.brand,
                  side: const BorderSide(color: C.brand),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _scanning ? null : _scanSms,
                icon: _scanning
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sms_outlined),
                label: const Text('SMS'),
              ),
            ),
          ],
        ]),
      ]),
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.inbox_rounded, size: 56, color: C.muted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('Belum ada pemeriksaan', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Tempel pesan di atas lalu tekan Periksa.',
                textAlign: TextAlign.center, style: TextStyle(color: C.muted)),
          ]),
        ),
      );

  Widget _tile(Detection d) {
    final color = riskColor(d.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgCard(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(riskIcon(d.level), color: color, size: 22),
        ),
        title: Text(d.message, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.3)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(d.reasons.isEmpty ? 'Tidak ada pola mencurigakan' : d.reasons.first.text,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.muted, fontSize: 12.5)),
        ),
        trailing: RiskBadge(level: d.level, score: d.score),
        onTap: () => _open(d),
      ),
    );
  }
}
