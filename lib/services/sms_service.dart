// Memilih implementasi sesuai platform:
// - web  -> sms_web.dart (stub, fitur baca SMS dimatikan)
// - lain -> sms_io.dart  (Android: baca SMS via another_telephony)
export 'sms_io.dart' if (dart.library.html) 'sms_web.dart';
