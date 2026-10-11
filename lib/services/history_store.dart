import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection.dart';

/// Menyimpan riwayat pemeriksaan di perangkat (tanpa server).
class HistoryStore {
  static const _key = 'awas_scam_history_v1';
  static const _max = 200;

  Future<List<Detection>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final out = <Detection>[];
    for (final s in raw) {
      try {
        out.add(Detection.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* abaikan entri rusak */}
    }
    return out;
  }

  Future<void> add(Detection d) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.insert(0, jsonEncode(d.toJson()));
    if (raw.length > _max) raw.removeRange(_max, raw.length);
    await prefs.setStringList(_key, raw);
  }

  Future<void> setFeedback(Detection target, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final stamp = target.checkedAt.toIso8601String();
    for (var i = 0; i < raw.length; i++) {
      try {
        final j = jsonDecode(raw[i]) as Map<String, dynamic>;
        if (j['checkedAt'] == stamp && j['message'] == target.message) {
          j['feedback'] = value;
          raw[i] = jsonEncode(j);
          break;
        }
      } catch (_) {}
    }
    await prefs.setStringList(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
