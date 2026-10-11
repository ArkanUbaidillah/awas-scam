import 'package:flutter_test/flutter_test.dart';
import 'package:awas_scam/models/detection.dart';
import 'package:awas_scam/services/detector.dart';

void main() {
  group('SmishingDetector', () {
    test('undian + minta PIN + domain palsu = bahaya', () {
      final d = SmishingDetector.analyze(
          'SELAMAT! Anda pemenang undian BRI. Klaim di http://bri-hadiah.xyz dengan PIN ATM anda. Segera!!!');
      expect(d.level, RiskLevel.bahaya);
      expect(d.reasons, isNotEmpty);
    });

    test('OTP asli yang melarang membagikan kode TIDAK dianggap scam', () {
      final d = SmishingDetector.analyze(
          'OTP BCA Anda 552109. JANGAN beri kode ini ke siapa pun termasuk pihak bank.');
      expect(d.level, RiskLevel.aman);
    });

    test('permintaan membagikan OTP terdeteksi', () {
      final d = SmishingDetector.analyze(
          'Mohon sebutkan kode OTP anda ke petugas untuk verifikasi akun DANA.');
      expect(d.level, anyOf(RiskLevel.bahaya, RiskLevel.waspada));
      expect(d.reasons.any((r) => r.category == 'otp_share'), true);
    });

    test('pesan biasa aman (skor rendah)', () {
      final d = SmishingDetector.analyze('Bu, besok kumpul tugas jam 9 di lab ya.');
      expect(d.level, RiskLevel.aman);
      expect(d.score, lessThan(22));
    });

    test('model AI menangkap modus yang luput dari aturan', () {
      // tak ada kata kunci aturan, tetapi model menilai mirip penipuan
      final d = SmishingDetector.analyze(
          'Kak tolong isiin pulsa dulu 50rb nanti aku transfer balik ya');
      expect(d.mlScore, greaterThan(50));
    });

    test('analisis tautan menandai domain peniru merek', () {
      final u = SmishingDetector.analyzeUrl('http://bca-verify.my.id/login');
      expect(u.level, anyOf(RiskLevel.bahaya, RiskLevel.waspada));
      expect(u.findings, isNotEmpty);
    });
  });
}
