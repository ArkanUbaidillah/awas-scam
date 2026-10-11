import 'detection.dart';

class UrlFinding {
  final bool danger; // true = merah, false = catatan
  final String text;
  const UrlFinding(this.danger, this.text);
}

class UrlCheck {
  final String url;
  final String host;
  final RiskLevel level;
  final List<UrlFinding> findings;
  const UrlCheck({
    required this.url,
    required this.host,
    required this.level,
    required this.findings,
  });
}
