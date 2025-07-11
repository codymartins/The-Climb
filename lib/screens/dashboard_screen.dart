// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'checkin_screen.dart';
// import 'phase_preview_screen.dart';


// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int currentPhase = 1;
//   int phaseStreak = 0;
//   int phaseMediaCount = 0;
//   static const int phaseGoalStreak = 14;
//   static const int phaseGoalMedia = 7;

//   @override
//   void initState() {
//     super.initState();
//     loadProgress();
//   }

//   Future<void> loadProgress() async {
//     final prefs = await SharedPreferences.getInstance();

//     int storedPhase = prefs.getInt('currentPhase') ?? 1;
//     int streak = prefs.getInt('phase${storedPhase}Streak') ?? 0;
//     int media = prefs.getInt('phase${storedPhase}Media') ?? 0;

//     // Phase promotion logic (works for Phase 1 through 4)
//     if (streak >= 14 && media >= 7 && storedPhase < 5) {
//       final nextPhase = storedPhase + 1;
//       await prefs.setInt('currentPhase', nextPhase);
//       await prefs.setInt('phase${nextPhase}Streak', 0);
//       await prefs.setInt('phase${nextPhase}Media', 0);
//       storedPhase = nextPhase;
//       streak = 0;
//       media = 0;
//     }


//     final updatedPhase = prefs.getInt('currentPhase') ?? 1;

//     setState(() {
//       currentPhase = updatedPhase;
//       phaseStreak = streak;
//       phaseMediaCount = media;
//     });
//   }


//   Widget buildPhaseCard(int phaseNumber, String title, String summary) {
//     final unlocked = currentPhase >= phaseNumber;
//     final isCurrent = currentPhase == phaseNumber;

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       color: unlocked ? Colors.white : Colors.grey.shade300,
//       child: ListTile(
//         leading: Icon(
//           unlocked ? Icons.lock_open : Icons.lock,
//           color: unlocked ? Colors.green : Colors.grey,
//         ),
//         title: Text("Phase $phaseNumber: $title"),
//         subtitle: Text(summary),
//         trailing: isCurrent ? const Text("Current") : null,
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PhasePreviewScreen(
//                 phaseNumber: phaseNumber,
//                 unlocked: unlocked,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Start The Climb')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             Text("Current Phase: $currentPhase", style: Theme.of(context).textTheme.headlineMedium),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CheckInScreen(phase: currentPhase),
//                   ),
//                 );
//                 await loadProgress(); // Refresh
//               },
//               child: const Text("Start Today’s Check-In"),
//             ),
//             const SizedBox(height: 24),
//             Text("Your Progress", style: Theme.of(context).textTheme.titleMedium),           
//             Text("Daily Check-In Streak: $phaseStreak / $phaseGoalStreak"),
//             SizedBox(
//               height: 8,
//             ),
//             LinearProgressIndicator(
//               value: (phaseStreak / phaseGoalStreak).clamp(0.0, 1.0),
//               backgroundColor: Colors.grey.shade300,
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2D5C)),
//             ),

//             SizedBox(height: 16),

//             Text("Reference Media Completed: $phaseMediaCount / $phaseGoalMedia"),
//             SizedBox(
//               height: 8,
//             ),
//             LinearProgressIndicator(
//               value: (phaseMediaCount / phaseGoalMedia).clamp(0.0, 1.0),
//               backgroundColor: Colors.grey.shade300,
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2D5C)),
//             ),

//             const SizedBox(height: 24),
//             Text("Phases", style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 12),
//             buildPhaseCard(1, "Awareness", "See clearly. Wake up to your potential."),
//             buildPhaseCard(2, "Discipline", "Train your will. Build non-negotiables."),
//             buildPhaseCard(3, "Growth", "Seek challenge. Confront fear."),
//             buildPhaseCard(4, "Reflection", "Understand yourself. Learn from failure."),
//             buildPhaseCard(5, "Mastery", "Live in alignment. Lead with integrity."),
//           ],
//         ),
//       ),
//     );
//   }
// }
