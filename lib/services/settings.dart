import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detector.dart';

class AppSettings {
  final bool dark;
  final int sensitivity; // 0 rendah, 1 normal, 2 tinggi
  const AppSettings({required this.dark, required this.sensitivity});
}

class SettingsController extends ValueNotifier<AppSettings> {
  SettingsController() : super(const AppSettings(dark: false, sensitivity: 1));
  static const _kDark = 'awas_dark';
  static const _kSens = 'awas_sens';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final sens = p.getInt(_kSens) ?? 1;
    SmishingDetector.sensitivity = sens;
    value = AppSettings(dark: p.getBool(_kDark) ?? false, sensitivity: sens);
  }

  Future<void> setDark(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDark, v);
    value = AppSettings(dark: v, sensitivity: value.sensitivity);
  }

  Future<void> setSensitivity(int v) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kSens, v);
    SmishingDetector.sensitivity = v;
    value = AppSettings(dark: value.dark, sensitivity: v);
  }
}

final settings = SettingsController();
