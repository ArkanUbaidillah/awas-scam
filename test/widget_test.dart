import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awas_scam/main.dart';

void main() {
  testWidgets('Aplikasi menampilkan beranda & navigasi', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AwasScamApp());
    await tester.pump();
    expect(find.text('Awas Scam'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget); // label navigasi bawah
    expect(find.text('Edukasi'), findsOneWidget);
  });
}
