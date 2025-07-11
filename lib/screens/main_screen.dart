import 'package:flutter/material.dart';
// import 'dashboard_screen.dart';
import 'reference_library_screen.dart';
import 'journal_history_screen.dart';
import 'progress_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vice_tracker.dart';

class MainScreen extends StatefulWidget {
  final int phase;

  const MainScreen({super.key, required this.phase});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  int currentPhase = 1; // This should be updated when the user progresses

  @override
  void initState() {
    super.initState();
    loadPhase();
  }

  Future<void> loadPhase() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPhase = prefs.getInt('currentPhase') ?? 1;
    setState(() {
      currentPhase = storedPhase;
    });
  }

  List<Widget> pages() => [
    ProgressPage(currentPhase: currentPhase),
    // const DashboardScreen(),
    const ReferenceLibraryScreen(),
    const JournalHistoryScreen(),
    const ViceTrackerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == 3) { // Progress Page tab index
            await loadPhase(); // Reload phase from SharedPreferences
          }
          setState(() => _currentIndex = index);
        },
        selectedItemColor: const Color.fromARGB(255, 42, 46, 51),
        unselectedItemColor: Colors.grey,
        items: const [
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.dashboard),
        //     label: 'Dashboard',
        //   ),
          BottomNavigationBarItem(
            icon: Icon(Icons.terrain), 
            label: 'Progress Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note), // 📝 or 📓 icon
            label: 'Journal History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded), 
            label: 'Vice Tracker',
          ),
        ],
      ),
    );
  }
}


