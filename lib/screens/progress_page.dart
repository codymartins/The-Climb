import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'phase_preview_screen.dart';
import '../screens/checkin_screen.dart';

class ProgressPage extends StatefulWidget {
  final int currentPhase;

  const ProgressPage({super.key, required this.currentPhase});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with WidgetsBindingObserver {
  int streak = 0;
  int mediaCount = 0;
  int currentPhase = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAllProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAllProgress();
    }
  }

  Future<void> _loadAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final phase = prefs.getInt('currentPhase') ?? widget.currentPhase;
    setState(() {
      currentPhase = phase;
      streak = prefs.getInt('phase${currentPhase}Streak') ?? 0;
      mediaCount = prefs.getInt('phase${currentPhase}Media') ?? 0;
    });
    await _checkAndAdvancePhase();
  }

  Future<void> _checkAndAdvancePhase() async {
    final prefs = await SharedPreferences.getInstance();
    if (streak >= 14 && mediaCount >= 7 && currentPhase < 5) {
      final newPhase = currentPhase + 1;
      await prefs.setInt('currentPhase', newPhase);
      await prefs.setInt('phase${newPhase}Streak', 0);
      await prefs.setInt('phase${newPhase}Media', 0);
      setState(() {
        currentPhase = newPhase;
        streak = 0;
        mediaCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Advanced to Phase $newPhase!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Offset> phasePositions = {
      1: const Offset(304, 577),
      2: const Offset(62, 471),
      3: const Offset(280, 427),
      4: const Offset(106, 313),
      5: const Offset(256, 218),
    };

    final Map<int, Offset> hikerPositions = {
      1: const Offset(232, 580),
      2: const Offset(130, 456),
      3: const Offset(217, 429),
      4: const Offset(170, 313),
      5: const Offset(180, 190),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Your Climb')),
      body: Stack(
        children: [
          // Background and animated elements
          Positioned.fill(
            child: Image.asset(
              'assets/mountain_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Cloud animation at the very top
          Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Lottie.asset('assets/cloud.json', fit: BoxFit.cover),
            ),
          ),
          // Progress bars side by side at the top, below the clouds
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                children: [
                  // Phase Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Check-In Streak",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        LinearProgressIndicator(
                          value: streak / 14,
                          minHeight: 8,
                          backgroundColor: Color.fromARGB(255, 250, 248, 248),
                          color: Color.fromARGB(255, 42, 46, 51),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "$streak / 14",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Media Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Media",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        LinearProgressIndicator(
                          value: mediaCount / 7,
                          minHeight: 8,
                          backgroundColor: const Color.fromARGB(255, 250, 248, 248),
                          color: Color.fromARGB(255, 42, 46, 51),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "$mediaCount / 7",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hiker
          if (hikerPositions.containsKey(currentPhase))
            Positioned(
              left: hikerPositions[currentPhase]!.dx,
              top: hikerPositions[currentPhase]!.dy,
              child: Column(
                children: const [
                  Icon(Icons.hiking_sharp, color: Color.fromARGB(255, 64, 81, 90), size: 48),
                ],
              ),
            ),
          // Phase buttons
          ...phasePositions.entries.map((entry) {
            final phase = entry.key;
            final pos = entry.value;
            final unlocked = currentPhase >= phase;
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhasePreviewScreen(
                        phaseNumber: phase,
                        unlocked: unlocked,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Icon(
                      unlocked ? Icons.lock_open : Icons.lock,
                      color: unlocked ? const Color.fromARGB(255, 95, 150, 58) : Color.fromARGB(255, 71, 77, 85),
                      size: 40,
                    ),
                    Text(
                      "Phase $phase",
                      style: TextStyle(
                        color: unlocked ? Color.fromARGB(255, 95, 150, 58) : Color.fromARGB(255, 71, 77, 85),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Streak and Check-in buttons at the bottom center
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckInScreen(phase: currentPhase, period: 'AM'),
                      ),
                    ).then((_) async {
                      await _loadAllProgress();
                      await _checkAndAdvancePhase();
                    });
                  },
                  child: const Text("AM Check-In"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckInScreen(phase: currentPhase, period: 'PM'),
                      ),
                    ).then((_) {
                      // Reload progress when returning from check-in
                      _loadAllProgress();
                    });
                  },
                  child: const Text("PM Check-In"),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.fast_forward),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          // Change to any phase you want to test, e.g. phase 2
          await prefs.setInt('currentPhase', 2);
          setState(() {});
        },
      ),
    );
  }
}
