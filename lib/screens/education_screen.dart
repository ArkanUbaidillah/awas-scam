import 'package:flutter/material.dart';
import '../theme.dart';

class _Modus {
  final IconData icon;
  final String judul;
  final String ciri;
  final String tindakan;
  const _Modus(this.icon, this.judul, this.ciri, this.tindakan);
}

const _list = <_Modus>[
  _Modus(Icons.card_giftcard_rounded, 'Undian / hadiah palsu',
      'Mengaku dari bank/e-commerce, bilang kamu menang hadiah besar, minta klik tautan atau bayar "pajak hadiah".',
      'Perusahaan asli tidak memungut biaya untuk hadiah. Abaikan dan hapus.'),
  _Modus(Icons.password_rounded, 'Phishing OTP / PIN',
      'Meminta kamu menyebutkan kode OTP, PIN, atau password "untuk verifikasi".',
      'JANGAN pernah memberikan OTP/PIN ke siapa pun. Bank tidak pernah memintanya.'),
  _Modus(Icons.family_restroom_rounded, 'Mama/papa minta pulsa',
      'Mengaku keluarga dengan "nomor baru", lalu minta dibelikan pulsa atau ditransfer uang.',
      'Telepon langsung ke nomor keluarga yang kamu simpan untuk memastikan.'),
  _Modus(Icons.local_shipping_rounded, 'Paket tertahan / bea cukai',
      'Mengaku dari ekspedisi/bea cukai, bilang paketmu tertahan dan harus bayar denda ke rekening pribadi.',
      'Bea cukai tidak menagih ke rekening pribadi. Cek resi di aplikasi resmi ekspedisi.'),
  _Modus(Icons.account_balance_wallet_rounded, 'Pinjol ilegal',
      'Menawarkan pinjaman "cair cepat tanpa jaminan", sering lewat SMS/WA massal.',
      'Pinjaman resmi terdaftar di OJK. Hindari yang menawarkan lewat pesan pribadi.'),
  _Modus(Icons.work_outline_rounded, 'Lowongan kerja palsu',
      'Gaji besar, kerja ringan dari rumah ("like & subscribe"), lalu minta deposit atau data pribadi.',
      'Pekerjaan asli tidak meminta uang di awal. Jangan bayar untuk "diterima kerja".'),
  _Modus(Icons.link_off_rounded, 'Tautan menyamar',
      'Domain mirip merek asli (mis. bri-xxx.xyz), pakai pemendek tautan, atau karakter aneh.',
      'Ketik sendiri alamat resmi di browser; jangan klik tautan dari pesan tak dikenal.'),
  _Modus(Icons.lock_clock_rounded, 'Akun akan diblokir',
      'Menakut-nakuti bahwa akunmu bermasalah/akan diblokir, minta login di tautan palsu.',
      'Buka aplikasi resmi langsung, bukan lewat tautan di pesan.'),
];

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: brandAppBar('Edukasi'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Kenali modus penipuan umum di Indonesia dan cara menanggapinya.',
              style: TextStyle(color: C.muted)),
          const SizedBox(height: 14),
          ..._list.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: bgCard(context), borderRadius: BorderRadius.circular(16), boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: C.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(m.icon, color: C.brand, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(m.judul, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                  ]),
                  const SizedBox(height: 10),
                  Text(m.ciri, style: const TextStyle(height: 1.4, fontSize: 13.5)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: C.safe.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.shield_rounded, size: 17, color: C.safe),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m.tindakan, style: const TextStyle(height: 1.35, fontSize: 13, color: Color(0xFF127150)))),
                    ]),
                  ),
                ]),
              )),
        ],
      ),
    );
  }
}
