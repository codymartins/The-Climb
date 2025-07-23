import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhasePreviewScreen extends StatelessWidget {
  final int phaseNumber;
  final bool unlocked;

  const PhasePreviewScreen({super.key, required this.phaseNumber, required this.unlocked});
  
  Future<void> _startPhase(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPhase', phaseNumber);
    await prefs.setInt('phase${phaseNumber}Day', 0); // start at day 1
    await prefs.setInt('phase${phaseNumber}Streak', 0); // optional reset 
    Navigator.pop(context);
  }

  Widget buildSection({
    required String title,
    required String body,
    IconData? icon,
    Color? color,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Icon(icon, color: color ?? Colors.blueGrey, size: 32),
            if (icon != null) const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> sections = [];

    if (phaseNumber == 1) {
      sections = [
        buildSection(
          title: "Phase 1: Awakening to Potential",
          body: "See the Truth. Start the Climb.",
          icon: Icons.local_fire_department,
          color: Colors.redAccent,
        ),
        buildSection(
          title: "What is this phase?",
          body: "This phase is about waking up — seeing the gap between who you are and who you could be.\n"
                "You’ll confront your environment, your habits, and your mindset to ignite real change.",
          icon: Icons.visibility,
          color: Colors.blueAccent,
        ),
        buildSection(
          title: "Why It Matters",
          body: "You’ve been asleep at the wheel. This phase forces clarity.\n"
                "No more drifting — only purpose, honesty, and momentum.",
          icon: Icons.warning,
          color: Colors.orangeAccent,
        ),
        buildSection(
          title: "What You’ll Do",
          body: "• Journal hard truths about who you are\n"
                "• Cut distractions and audit your media\n"
                "• Write your vision of the man you’re meant to become\n"
                "• Ask daily: “What would make me proud today?”\n"
                "• Clean your space to reflect your higher standards",
          icon: Icons.settings,
          color: Colors.grey,
        ),
        buildSection(
          title: "This is where it begins.",
          body: "Get clear. Get uncomfortable. Get moving.",
          icon: Icons.terrain,
          color: Colors.green,
        ),
      ];
    } else if (phaseNumber == 2) {
      sections = [
        buildSection(
          title: "Phase 2: Discipline & Structure",
          body: "Build Systems. Become Relentless.",
          icon: Icons.grid_on,
          color: Colors.brown,
        ),
        buildSection(
          title: "What is this phase?",
          body: "Now it's about showing up, every day.\n"
                "You’ll create structure, fight excuses, and train your mind to move with discipline — not emotion.",
          icon: Icons.repeat,
          color: Colors.blueGrey,
        ),
        buildSection(
          title: "Why It Matters",
          body: "Potential without structure is wasted.\n"
                "This phase turns your vision into daily execution. No more chaos. No more negotiating with yourself.",
          icon: Icons.warning_amber,
          color: Colors.orange,
        ),
        buildSection(
          title: "What You’ll Do",
          body: "• Build simple, repeatable routines\n"
                "• Track your execution — ✅ or ❌, no fluff\n"
                "• Rest with intention, not to escape\n"
                "• Finish before you celebrate\n"
                "• Crush excuses before they take root",
          icon: Icons.settings_suggest,
          color: Colors.grey,
        ),
        buildSection(
          title: "This is where the work gets real.",
          body: "Discipline isn’t a feeling — it’s a system.",
          icon: Icons.handyman,
          color: Colors.brown,
        ),
      ];
    } else if (phaseNumber == 3) {
      sections = [
        buildSection(
          title: "Phase 3: Progress Over Perfection",
          body: "Take the Step. Stop Waiting.",
          icon: Icons.rocket_launch,
          color: Colors.deepPurple,
        ),
        buildSection(
          title: "What is this phase?",
          body: "This phase is about momentum, not mastery.\n"
                "You’ll silence perfectionism, embrace imperfect action, and keep climbing — even when it’s messy.",
          icon: Icons.directions_run,
          color: Colors.indigo,
        ),
        buildSection(
          title: "Why It Matters",
          body: "Perfection is the enemy of progress.\n"
                "You don’t need flawless days — you need forward motion. This phase teaches you to move anyway.",
          icon: Icons.warning_amber,
          color: Colors.orange,
        ),
        buildSection(
          title: "What You’ll Do",
          body: "• Finish before you feel ready\n"
                "• Log real wins — even the small ones\n"
                "• Act today, not “tomorrow”\n"
                "• Bounce back fast from failure\n"
                "• Fall in love with the process, not the end",
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        buildSection(
          title: "This is where grit is built.",
          body: "You won’t be perfect — but you will get better.",
          icon: Icons.fitness_center,
          color: Colors.deepPurple,
        ),
      ];
    } else if (phaseNumber == 4) {
      sections = [
        buildSection(
          title: "Phase 4: Inner Freedom",
          body: "Master Yourself. Silence the Noise.",
          icon: Icons.self_improvement,
          color: Colors.blueGrey,
        ),
        buildSection(
          title: "What is this phase?",
          body: "This phase is about becoming unshakable — no longer ruled by urges, distractions, or outside approval.\n"
                "You’ll build clarity, stillness, and strength from within.",
          icon: Icons.spa,
          color: Colors.teal,
        ),
        buildSection(
          title: "Why It Matters",
          body: "A man ruled by chaos is never free.\n"
                "When you master your emotions and detach from the world’s grip, you unlock a deeper power: self-possession.",
          icon: Icons.warning_amber,
          color: Colors.orange,
        ),
        buildSection(
          title: "What You’ll Do",
          body: "• Practice solitude without distractions\n"
                "• Reflect daily on your integrity\n"
                "• Pause before reacting to emotion\n"
                "• Own your identity — no more blaming others\n"
                "• Replace inner weakness with strength-building habits",
          icon: Icons.psychology,
          color: Colors.blueGrey,
        ),
        buildSection(
          title: "This is where freedom begins.",
          body: "Still mind. Strong will. Unshakable soul.",
          icon: Icons.security,
          color: Colors.teal,
        ),
      ];
    } else if (phaseNumber == 5) {
      sections = [
        buildSection(
          title: "Phase 5: Becoming Useful & Compassionate",
          body: "Live Beyond Yourself. Lead With Strength.",
          icon: Icons.volunteer_activism,
          color: Colors.green,
        ),
        buildSection(
          title: "What is this phase?",
          body: "This phase is about service, humility, and legacy.\n"
                "You’ll use what you’ve built — not to dominate, but to uplift others with purpose and compassion.",
          icon: Icons.people,
          color: Colors.blueGrey,
        ),
        buildSection(
          title: "Why It Matters",
          body: "The highest form of strength is service.\n"
                "Without giving back, even greatness feels hollow. This phase fills your life with meaning that endures.",
          icon: Icons.warning_amber,
          color: Colors.orange,
        ),
        buildSection(
          title: "What You’ll Do",
          body: "• Lighten someone’s load every day\n"
                "• Lead by example, not ego\n"
                "• Own your influence in every room\n"
                "• Celebrate quietly — lift, don’t boast\n"
                "• Reflect weekly: “Who did I help?”",
          icon: Icons.emoji_people,
          color: Colors.green,
        ),
        buildSection(
          title: "This is where impact begins.",
          body: "Strength becomes legacy. Power becomes purpose.",
          icon: Icons.eco,
          color: Colors.green,
        ),
      ];
    } else {
      sections = [
        const Center(child: Text('Preview not available for this phase yet.')),
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text('Phase $phaseNumber Preview')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: sections,
              ),
            ),
            if (unlocked)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.flag),
                    label: const Text("Start This Phase"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Reset Progress?"),
                          content: const Text(
                            "Starting this phase will reset your progress and streak for this phase. Are you sure you want to continue?"
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context), // Cancel
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close dialog
                                await _startPhase(context); // Actually start phase
                              },
                              child: const Text("Start Phase"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
