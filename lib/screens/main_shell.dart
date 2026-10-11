import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'url_check_screen.dart';
import 'education_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  Widget _tab() {
    switch (_index) {
      case 1:
        return const StatsScreen();
      case 2:
        return const UrlCheckScreen();
      case 3:
        return const EducationScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Periksa'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistik'),
          NavigationDestination(icon: Icon(Icons.link), label: 'Tautan'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Edukasi'),
        ],
      ),
    );
  }
}
