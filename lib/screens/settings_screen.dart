import 'package:flutter/material.dart';
import '../services/settings.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _sensLabel = ['Rendah', 'Normal', 'Tinggi'];
  static const _sensDesc = [
    'Hanya menandai yang sangat mencurigakan (lebih sedikit peringatan).',
    'Keseimbangan yang disarankan.',
    'Menandai lebih banyak pesan (lebih waspada, bisa lebih banyak salah tandai).',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: brandAppBar('Pengaturan'),
      body: ValueListenableBuilder<AppSettings>(
        valueListenable: settings,
        builder: (_, s, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(color: bgCard(context), borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                value: s.dark,
                onChanged: settings.setDark,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Mode gelap'),
                subtitle: const Text('Tema gelap untuk mata & malam hari'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Sensitivitas deteksi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Rendah')),
                ButtonSegment(value: 1, label: Text('Normal')),
                ButtonSegment(value: 2, label: Text('Tinggi')),
              ],
              selected: {s.sensitivity},
              onSelectionChanged: (sel) => settings.setSensitivity(sel.first),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bgCard(context), borderRadius: BorderRadius.circular(14)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.tune_rounded, size: 18, color: C.brand),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('${_sensLabel[s.sensitivity]} — ${_sensDesc[s.sensitivity]}',
                      style: const TextStyle(height: 1.4, fontSize: 13.5)),
                ),
              ]),
            ),
            const SizedBox(height: 28),
            const Text('Tentang', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            const Text(
              'Awas Scam menilai pesan sepenuhnya di perangkatmu — tanpa internet dan tanpa mengirim '
              'isi pesan ke mana pun. Hasilnya bantuan deteksi, bukan kepastian.',
              style: TextStyle(color: C.muted, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
