import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'reference_library_screen.dart';
import 'journal_history_screen.dart';


class MainScreen extends StatefulWidget {
  final int phase;

  const MainScreen({super.key, required this.phase});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreen(),
      const ReferenceLibraryScreen(),
      const JournalHistoryScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1F2D5C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note), // 📝 or 📓 icon
            label: 'Journal History',
          ),
        ],
      ),
    );
  }
}


