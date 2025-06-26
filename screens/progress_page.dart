import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Add this import
import 'phase_preview_screen.dart';

class ProgressPage extends StatelessWidget {
  final int currentPhase;

  const ProgressPage({super.key, required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    final Map<int, Offset> phasePositions = {
      1: const Offset(304, 577),
      2: const Offset(62, 471),
      3: const Offset(280, 427),
      4: const Offset(106, 313),
      5: const Offset(170, 183),
    };

    // Separate hiker positions for each phase (adjust these as needed)
    final Map<int, Offset> hikerPositions = {
      1: const Offset(232, 580),
      2: const Offset(130, 456),
      3: const Offset(217, 429),
      4: const Offset(190, 330),
      5: const Offset(205, 210),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Your Climb')),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/mountain_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Animated clouds
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SizedBox(
              width: 600,
              height: 300,
              child: Lottie.asset('assets/cloud.json'),
            ),
          ),
          // Animated Hiker (now uses hikerPositions)
          if (hikerPositions.containsKey(currentPhase))
            Positioned(
              left: hikerPositions[currentPhase]!.dx,
              top: hikerPositions[currentPhase]!.dy,
              child: Column(
                children: const [
                  Icon(Icons.hiking, color: Colors.blueGrey, size: 48),
                ],
              ),
            ),
          // Phase buttons at checkpoints:
          ...phasePositions.entries.map((entry) {
            final phase = entry.key;
            final pos = entry.value;
            final unlocked = currentPhase >= phase;
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onTap: unlocked
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhasePreviewScreen(
                              phaseNumber: phase,
                              unlocked: unlocked,
                            ),
                          ),
                        );
                      }
                    : null,
                child: Column(
                  children: [
                    Icon(
                      unlocked ? Icons.lock_open : Icons.lock,
                      color: unlocked ? Colors.green : Colors.blueGrey,
                      size: 40,
                    ),
                    Text(
                      "Phase $phase",
                      style: TextStyle(
                        color: unlocked ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
