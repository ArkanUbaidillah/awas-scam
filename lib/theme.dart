import 'package:flutter/material.dart';
import 'models/detection.dart';

// Identitas: indigo tengah-malam (tepercaya) + aksen emas (lencana penjaga).
class C {
  static const brand = Color(0xFF1B2A4A);
  static const brandDark = Color(0xFF111D38);
  static const gold = Color(0xFFF2A900);
  static const surface = Color(0xFFF4F6FB);
  static const ink = Color(0xFF1B2A4A);
  static const muted = Color(0xFF6B7280);
  static const safe = Color(0xFF159A68);
  static const warn = Color(0xFFE0912F);
  static const danger = Color(0xFFDE3B3B);

  // gelap
  static const darkBg = Color(0xFF0F1420);
  static const darkCard = Color(0xFF1B2335);
  static const darkField = Color(0xFF141A28);
  static const darkInk = Color(0xFFE8EAF2);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand, brandDark],
  );
}

bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color bgCard(BuildContext c) => _isDark(c) ? C.darkCard : Colors.white;
Color inputFill(BuildContext c) => _isDark(c) ? C.darkField : C.surface;
Color hairline(BuildContext c) => _isDark(c) ? Colors.white10 : Colors.black12;

ThemeData buildTheme() => _base(Brightness.light);
ThemeData buildDarkTheme() => _base(Brightness.dark);

ThemeData _base(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: C.brand, brightness: b).copyWith(
    surface: dark ? C.darkCard : Colors.white,
  );
  final ink = dark ? C.darkInk : C.ink;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? C.darkBg : C.surface,
    textTheme: const TextTheme().apply(bodyColor: ink, displayColor: ink),
    cardTheme: CardThemeData(
      color: dark ? C.darkCard : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    dividerTheme: DividerThemeData(color: dark ? Colors.white12 : Colors.black12),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? C.darkCard : Colors.white,
      indicatorColor: C.gold.withValues(alpha: dark ? 0.22 : 0.18),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: ink),
      ),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? (dark ? C.gold : C.brand) : C.muted,
          )),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );
}

Color riskColor(RiskLevel level) => switch (level) {
      RiskLevel.aman => C.safe,
      RiskLevel.waspada => C.warn,
      RiskLevel.bahaya => C.danger,
    };

IconData riskIcon(RiskLevel level) => switch (level) {
      RiskLevel.aman => Icons.verified_user_rounded,
      RiskLevel.waspada => Icons.warning_rounded,
      RiskLevel.bahaya => Icons.gpp_bad_rounded,
    };

String riskHeadline(RiskLevel level) => switch (level) {
      RiskLevel.aman => 'Tampak aman',
      RiskLevel.waspada => 'Hati-hati',
      RiskLevel.bahaya => 'Kemungkinan penipuan',
    };

PreferredSizeWidget brandAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    foregroundColor: Colors.white,
    backgroundColor: C.brand,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    actions: actions,
    flexibleSpace: const DecoratedBox(decoration: BoxDecoration(gradient: C.brandGradient)),
  );
}
