import 'package:flutter/foundation.dart';
import 'package:another_telephony/telephony.dart';

/// Membaca SMS kotak masuk. Hanya Android; platform lain mengembalikan kosong.
class SmsService {
  final Telephony _telephony = Telephony.instance;

  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> requestPermission() async {
    if (!supported) return false;
    final granted = await _telephony.requestSmsPermissions;
    return granted ?? false;
  }

  Future<List<String>> readInbox({int limit = 50}) async {
    if (!supported) return [];
    final messages = await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );
    return messages
        .map((m) => m.body ?? '')
        .where((b) => b.trim().isNotEmpty)
        .take(limit)
        .toList();
  }
}
