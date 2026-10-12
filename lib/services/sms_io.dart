/// Baca SMS otomatis dinonaktifkan (plugin another_telephony dilepas agar
/// build Android stabil & bebas warning KGP). Pengguna cukup menempel pesan
/// secara manual. API dipertahankan agar kode lain tetap kompilasi.
class SmsService {
  bool get supported => false;
  Future<bool> requestPermission() async => false;
  Future<List<String>> readInbox({int limit = 50}) async => const [];
}
