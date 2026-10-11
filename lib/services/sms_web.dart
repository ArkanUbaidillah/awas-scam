/// Stub web: membaca SMS tidak tersedia di browser.
class SmsService {
  bool get supported => false;
  Future<bool> requestPermission() async => false;
  Future<List<String>> readInbox({int limit = 50}) async => const [];
}
