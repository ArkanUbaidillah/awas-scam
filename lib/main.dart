import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'services/settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  runApp(const AwasScamApp());
}

class AwasScamApp extends StatelessWidget {
  const AwasScamApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: settings,
      builder: (_, s, __) => MaterialApp(
        title: 'Awas Scam',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: s.dark ? ThemeMode.dark : ThemeMode.light,
        home: const MainShell(),
      ),
    );
  }
}
