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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen for lifecycle changes
    loadProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload progress when returning to the page
      loadProgress();
    }
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt('phase${widget.currentPhase}Streak') ?? 0;
      mediaCount = prefs.getInt('phase${widget.currentPhase}Media') ?? 0;
    });
    await checkAndAdvancePhase();

    // Show congrats dialog only if justAdvancedPhase is true
    final justAdvanced = prefs.getBool('justAdvancedPhase') ?? false;
    if (justAdvanced && mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Congratulations!"),
          content: Text("You've completed Phase ${widget.currentPhase - 1}!\nWelcome to Phase ${widget.currentPhase}."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      await prefs.setBool('justAdvancedPhase', false);
    }
  }

  Future<void> checkAndAdvancePhase() async {
    final prefs = await SharedPreferences.getInstance();
    // Only advance if both streak and media are complete and not already at max phase
    if (streak >= 14 && mediaCount >= 7 && widget.currentPhase < 5) {
      final newPhase = widget.currentPhase + 1;
      await prefs.setInt('currentPhase', newPhase);
      await prefs.setInt('phase${newPhase}Streak', 0);
      await prefs.setInt('phase${newPhase}Media', 0);
      await prefs.setBool('justAdvancedPhase', true); // <-- Set the flag
      if (!mounted) return;
      setState(() {}); // Update UI
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
          if (hikerPositions.containsKey(widget.currentPhase))
            Positioned(
              left: hikerPositions[widget.currentPhase]!.dx,
              top: hikerPositions[widget.currentPhase]!.dy,
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
            final unlocked = widget.currentPhase >= phase;
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
                        builder: (context) => CheckInScreen(phase: widget.currentPhase, period: 'AM'),
                      ),
                    ).then((_) async {
                      await loadProgress();
                      await checkAndAdvancePhase();
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
                        builder: (context) => CheckInScreen(phase: widget.currentPhase, period: 'PM'),
                      ),
                    ).then((_) {
                      // Reload progress when returning from check-in
                      loadProgress();
                    });
                  },
                  child: const Text("PM Check-In"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
