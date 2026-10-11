import '../models/detection.dart';

class Stats {
  final int total;
  final Map<RiskLevel, int> byLevel;
  final List<MapEntry<String, int>> topCategories;
  final List<int> last7Days; // jumlah ditandai per hari, index 0 = 6 hari lalu
  final int confirmed;
  final int falsePositive;

  const Stats({
    required this.total,
    required this.byLevel,
    required this.topCategories,
    required this.last7Days,
    required this.confirmed,
    required this.falsePositive,
  });

  int get flagged => (byLevel[RiskLevel.waspada] ?? 0) + (byLevel[RiskLevel.bahaya] ?? 0);

  static const Map<String, String> categoryLabel = {
    'hadiah': 'Hadiah/undian',
    'urgensi': 'Mendesak',
    'minta_data': 'Minta data rahasia',
    'otp_mention': 'Sebut OTP',
    'otp_share': 'Minta bagikan OTP',
    'keluarga': 'Mama/papa minta',
    'pinjol': 'Pinjol',
    'kerja': 'Loker palsu',
    'otoritas': 'Bea cukai/otoritas',
    'transfer': 'Minta transfer',
    'link': 'Tautan mencurigakan',
    'gaya': 'Gaya spam',
    'ai': 'Terdeteksi AI',
  };

  static Stats from(List<Detection> items) {
    final byLevel = <RiskLevel, int>{
      RiskLevel.aman: 0,
      RiskLevel.waspada: 0,
      RiskLevel.bahaya: 0,
    };
    final cats = <String, int>{};
    final days = List<int>.filled(7, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var confirmed = 0, fp = 0;

    for (final d in items) {
      byLevel[d.level] = (byLevel[d.level] ?? 0) + 1;
      for (final r in d.reasons) {
        cats[r.category] = (cats[r.category] ?? 0) + 1;
      }
      if (d.feedback == true) confirmed++;
      if (d.feedback == false) fp++;
      if (d.level != RiskLevel.aman) {
        final day = DateTime(d.checkedAt.year, d.checkedAt.month, d.checkedAt.day);
        final diff = today.difference(day).inDays;
        if (diff >= 0 && diff < 7) days[6 - diff]++;
      }
    }
    final top = cats.entries.toList()..sort((a, b) => b.value - a.value);
    return Stats(
      total: items.length,
      byLevel: byLevel,
      topCategories: top.take(6).toList(),
      last7Days: days,
      confirmed: confirmed,
      falsePositive: fp,
    );
  }
}
