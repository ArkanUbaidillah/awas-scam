import 'dart:math' as math;
import '../models/detection.dart';
import '../models/url_check.dart';
import 'ml_model.dart';

class _Rule {
  final String category;
  final int weight;
  final List<String> keywords;
  final String why;
  const _Rule(this.category, this.weight, this.keywords, this.why);
}

/// Mesin deteksi smishing hibrida (aturan pola + model AI ringan), berjalan
/// sepenuhnya di perangkat. Transparan: setiap keputusan disertai alasan.
class SmishingDetector {
  /// 0 = rendah, 1 = normal, 2 = tinggi. Disetel dari layar Pengaturan.
  static int sensitivity = 1;

  static const List<_Rule> _rules = [
    _Rule('hadiah', 34, [
      'selamat anda', 'anda terpilih', 'anda mendapat', 'pemenang', 'memenangkan',
      'undian', 'hadiah', 'klaim hadiah', 'poin anda', 'point reward', 'kode kupon',
      'grand prize', 'voucher', 'cashback gratis', 'dana kaget', 'saldo gratis',
    ], 'Klaim hadiah/undian — modus penipuan paling umum'),
    _Rule('urgensi', 20, [
      'segera', 'sekarang juga', 'dalam 24 jam', 'batas waktu', 'akan diblokir',
      'akan dinonaktifkan', 'terakhir hari ini', 'sebelum hangus', 'sblm hangus',
      'verifikasi sekarang', 'konfirmasi sekarang', 'jangan sampai hangus',
    ], 'Menekan dengan rasa mendesak'),
    _Rule('minta_data', 38, [
      'nomor rekening', 'no rekening', 'nomor kartu', 'nomor atm', 'pin atm',
      'masukkan pin', 'kata sandi', 'password', 'kode akses', 'data pribadi',
      'nik anda', 'nomor kk', 'cvv', 'm-pin', 'mpin',
    ], 'Meminta data rahasia (PIN/rekening/sandi)'),
    _Rule('otp_mention', 12, [
      'kode otp', 'kode verifikasi', 'kode sms', 'one time password',
    ], 'Menyebut kode OTP'),
    _Rule('otp_share', 42, [
      'sebutkan kode', 'berikan kode', 'bagikan kode', 'kirim kode', 'beritahu kode',
      'sebutkan otp', 'berikan otp', 'informasikan kode',
    ], 'Meminta kamu MEMBAGIKAN kode — bank asli tidak pernah begitu'),
    _Rule('keluarga', 28, [
      'ini mama', 'ini papa', 'hp mama', 'hp papa', 'mama lagi', 'papa lagi',
      'tolong beliin pulsa', 'lagi butuh uang', 'pinjam uang dulu', 'ini om',
      'ini tante', 'nomor baru mama', 'nomor baru papa',
    ], "Modus 'mama/papa minta pulsa/uang'"),
    _Rule('pinjol', 24, [
      'pinjaman cepat', 'dana cair', 'cair dalam', 'tanpa jaminan', 'tanpa agunan',
      'pinjaman online', 'cicilan ringan tanpa', 'langsung cair', 'dana tunai cepat',
    ], 'Tawaran pinjaman instan (pinjol ilegal)'),
    _Rule('kerja', 20, [
      'lowongan kerja', 'gaji besar', 'kerja dari rumah', 'part time', 'komisi besar',
      'penghasilan tambahan', 'admin olshop', 'like dan subscribe', 'join grup telegram',
      'tugas mudah penghasilan',
    ], 'Lowongan/penghasilan tak masuk akal'),
    _Rule('otoritas', 34, [
      'bea cukai', 'paket anda tertahan', 'paket tertahan', 'barang anda tertahan',
      'resi bermasalah', 'denda paket', 'pajak hadiah', 'petugas pajak',
      'tagihan menunggak akan',
    ], 'Mengatasnamakan otoritas/ekspedisi + minta bayar'),
    _Rule('transfer', 20, [
      'transfer ke rekening', 'kirim ke rekening', 'ke rekening berikut',
      'bayar biaya admin', 'biaya administrasi', 'top up dulu', 'isi saldo dulu',
      'uang tebusan', 'bayar dulu untuk',
    ], 'Diminta transfer/bayar di muka'),
  ];

  static const Set<String> _shorteners = {
    'bit.ly', 'tinyurl.com', 's.id', 'cutt.ly', 'ow.ly', 'rebrand.ly', 't.ly',
    'gg.gg', 'bit.do', 'shorturl.at', 'rb.gy', 'is.gd', 'v.gd', 'adf.ly', 'linktr.ee',
  };
  static const Set<String> _riskyTld = {
    'xyz', 'top', 'click', 'link', 'online', 'site', 'tk', 'ml', 'ga', 'cf', 'gq',
    'info', 'work', 'buzz', 'icu', 'live', 'vip', 'shop', 'fun',
  };
  static const List<String> _bankWords = [
    'bri', 'bca', 'bni', 'mandiri', 'dana', 'ovo', 'gopay', 'shopee', 'shopeepay',
    'seabank', 'jago', 'livin', 'brimo', 'blu', 'linkaja', 'bsi', 'cimb', 'jenius',
    'maybank', 'permata', 'tokopedia', 'lazada', 'pln', 'telkomsel',
  ];
  static const List<String> _protect = [
    'jangan beri', 'jangan berikan', 'jangan bagikan', 'jangan sebutkan',
    'jangan memberi', 'jangan informasikan', 'jangan kasih', 'rahasiakan',
    'jangan pernah memberikan',
  ];

  static final RegExp _urlRe = RegExp(
    r'(https?://[^\s]+|www\.[^\s]+|\b[a-z0-9][a-z0-9.-]*\.[a-z]{2,}(?:/[^\s]*)?)',
    caseSensitive: false,
  );
  static final RegExp _caps = RegExp(r'[A-Z]');
  static final RegExp _bang = RegExp(r'!');
  static final RegExp _trail = RegExp(r'[.,)]+$');
  static final RegExp _scheme = RegExp(r'^https?://');
  static final RegExp _token = RegExp(r'[a-z0-9]{3,}');

  static const Map<String, String> _leet = {
    '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's', '@': 'a',
  };

  static String _norm(String t) {
    final lower = t.toLowerCase();
    final sb = StringBuffer();
    for (var i = 0; i < lower.length; i++) {
      sb.write(_leet[lower[i]] ?? lower[i]);
    }
    return sb.toString();
  }

  /// Probabilitas 0..1 dari model AI (bag-of-words logistic regression).
  static double mlProbability(String text) {
    final toks = _token.allMatches(text.toLowerCase()).map((m) => m.group(0)!).toSet();
    var s = MlModel.bias;
    for (final t in toks) {
      s += MlModel.weights[t] ?? 0.0;
    }
    return 1 / (1 + math.exp(-s));
  }

  static Detection analyze(String text) {
    final reasons = <Reason>[];
    var rule = 0;
    final low = _norm(text);
    final raw = text.toLowerCase();
    final protective = _protect.any((p) => low.contains(p));

    for (final r in _rules) {
      if (r.category == 'otp_share' && protective) continue;
      if (r.keywords.any((k) => low.contains(_norm(k)))) {
        rule += r.weight;
        reasons.add(Reason(r.category, r.weight, r.why));
      }
    }

    for (final m in _urlRe.allMatches(raw)) {
      var u = m.group(0)!.replaceAll(_trail, '');
      final host = u.replaceFirst(_scheme, '').split('/').first.toLowerCase();
      final dom = host.startsWith('www.') ? host.substring(4) : host;
      final parts = dom.split('.');
      final base = parts.length >= 2 ? parts.sublist(parts.length - 2).join('.') : dom;
      final tld = parts.length > 1 ? parts.last : '';
      final first = parts.isNotEmpty ? parts.first : dom;
      if (_shorteners.contains(base)) {
        rule += 20;
        reasons.add(Reason('link', 20, 'Tautan pendek menyembunyikan tujuan ($dom)'));
      } else if (_bankWords.any((b) => first.contains(b)) &&
          !(dom.endsWith('.co.id') || dom.endsWith('.com'))) {
        rule += 32;
        reasons.add(Reason('link', 32, 'Domain meniru merek resmi ($dom)'));
      } else if (_riskyTld.contains(tld)) {
        rule += 16;
        reasons.add(Reason('link', 16, 'Domain .$tld sering dipakai penipuan'));
      }
      if (u.startsWith('http://')) {
        rule += 6;
        reasons.add(const Reason('link', 6, 'Tautan tidak terenkripsi (http)'));
      }
    }

    final capsCount = _caps.allMatches(text).length;
    final capsLimit = (text.length * 0.4) > 12 ? text.length * 0.4 : 12;
    if (capsCount > capsLimit) {
      rule += 8;
      reasons.add(const Reason('gaya', 8, 'Banyak HURUF KAPITAL (gaya spam)'));
    }
    if (_bang.allMatches(text).length >= 3) {
      rule += 5;
      reasons.add(const Reason('gaya', 5, 'Tanda seru berlebihan'));
    }
    if (rule > 100) rule = 100;

    final ml = (mlProbability(text) * 100).round();
    var score = (0.65 * rule + 0.35 * ml).round();
    if (score > 100) score = 100;

    if (ml >= 60 && !reasons.any((r) => r.category == 'ai')) {
      reasons.add(Reason('ai', ml, 'Model AI menilai pesan ini mirip pola penipuan ($ml%)'));
    }
    reasons.sort((a, b) => b.weight - a.weight);

    final bahayaCut = 50 - (sensitivity - 1) * 10;
    final waspadaCut = 22 - (sensitivity - 1) * 8;
    final level = score >= bahayaCut
        ? RiskLevel.bahaya
        : score >= waspadaCut
            ? RiskLevel.waspada
            : RiskLevel.aman;

    return Detection(
      message: text,
      score: score,
      ruleScore: rule,
      mlScore: ml,
      level: level,
      reasons: reasons,
      checkedAt: DateTime.now(),
    );
  }

  /// Analisis satu tautan secara mendalam (untuk layar Cek Tautan).
  static UrlCheck analyzeUrl(String input) {
    final findings = <UrlFinding>[];
    var danger = 0;
    var url = input.trim();
    if (!_scheme.hasMatch(url)) url = 'http://$url';
    final afterScheme = url.replaceFirst(_scheme, '');
    final host = afterScheme.split('/').first.split('?').first.toLowerCase();
    final dom = host.startsWith('www.') ? host.substring(4) : host;
    final parts = dom.split('.');
    final tld = parts.length > 1 ? parts.last : '';
    final base = parts.length >= 2 ? parts.sublist(parts.length - 2).join('.') : dom;
    final first = parts.isNotEmpty ? parts.first : dom;

    if (url.startsWith('http://')) {
      danger += 1;
      findings.add(const UrlFinding(false, 'Tidak terenkripsi (http), bukan https'));
    }
    if (_shorteners.contains(base)) {
      danger += 2;
      findings.add(UrlFinding(true, 'Pemendek tautan ($base) — tujuan asli disembunyikan'));
    }
    if (host.contains('xn--')) {
      danger += 3;
      findings.add(const UrlFinding(true, 'Domain memakai karakter non-Latin (punycode) — trik peniruan'));
    }
    if (RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host.split(':').first)) {
      danger += 3;
      findings.add(const UrlFinding(true, 'Alamat berupa IP mentah, bukan nama domain'));
    }
    if (afterScheme.contains('@')) {
      danger += 3;
      findings.add(const UrlFinding(true, "Memakai '@' di URL untuk menyamarkan tujuan asli"));
    }
    final brand = _bankWords.firstWhere(
        (b) => first.contains(b) && !(dom.endsWith('.co.id') || dom.endsWith('.com')),
        orElse: () => '');
    if (brand.isNotEmpty) {
      danger += 3;
      findings.add(UrlFinding(true, 'Mengandung nama merek "$brand" tapi domain bukan resmi'));
    }
    if (_riskyTld.contains(tld)) {
      danger += 2;
      findings.add(UrlFinding(true, 'Akhiran .$tld sering dipakai situs penipuan'));
    }
    if (parts.length >= 4) {
      danger += 1;
      findings.add(const UrlFinding(false, 'Subdomain bertingkat banyak — bisa menyamarkan domain asli'));
    }
    if (dom.length > 30) {
      danger += 1;
      findings.add(const UrlFinding(false, 'Nama domain sangat panjang'));
    }
    if (findings.isEmpty) {
      findings.add(const UrlFinding(false, 'Tidak ada pola mencurigakan yang jelas pada tautan ini'));
    }

    final level = danger >= 3
        ? RiskLevel.bahaya
        : danger >= 1
            ? RiskLevel.waspada
            : RiskLevel.aman;
    return UrlCheck(url: input.trim(), host: dom, level: level, findings: findings);
  }

  static String advice(RiskLevel level) => switch (level) {
        RiskLevel.bahaya =>
          'Jangan klik tautan apa pun, jangan balas, dan jangan beri kode/PIN. '
              'Hapus pesan ini. Jika mengatasnamakan bank, hubungi call center resmi.',
        RiskLevel.waspada =>
          'Pesan ini mencurigakan. Jangan terburu-buru. Verifikasi ke sumber resmi '
              'lewat nomor/aplikasi yang kamu simpan sendiri, bukan nomor di pesan ini.',
        RiskLevel.aman =>
          'Tidak terdeteksi pola penipuan yang jelas. Tetap waspada: jangan pernah '
              'membagikan OTP/PIN, dan periksa tautan sebelum mengklik.',
      };
}
