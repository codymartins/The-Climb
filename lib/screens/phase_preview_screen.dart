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

  @override
  Widget build(BuildContext context) {
    Widget phaseContent;

    if (phaseNumber == 1) {
      phaseContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🔥 Phase 1: Awakening to Potential",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "🧠 See the Truth. Start the Climb.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "This phase is about waking up — seeing the gap between who you are and who you could be.\n"
            "You’ll confront your environment, your habits, and your mindset to ignite real change.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "🚨 Why It Matters",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "You’ve been asleep at the wheel. This phase forces clarity.\n"
            "No more drifting — only purpose, honesty, and momentum.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚙️ What You’ll Do",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "• Journal hard truths about who you are\n"
            "• Cut distractions and audit your media\n"
            "• Write your vision of the man you’re meant to become\n"
            "• Ask daily: “What would make me proud today?”\n"
            "• Clean your space to reflect your higher standards",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⛰️ This is where it begins.\nGet clear. Get uncomfortable. Get moving.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    } else if (phaseNumber == 2) {
      phaseContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🧱 Phase 2: Discipline & Structure",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "🔁 Build Systems. Become Relentless.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Now it's about showing up, every day.\n"
            "You’ll create structure, fight excuses, and train your mind to move with discipline — not emotion.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚠️ Why It Matters",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Potential without structure is wasted.\n"
            "This phase turns your vision into daily execution. No more chaos. No more negotiating with yourself.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚙️ What You’ll Do",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "• Build simple, repeatable routines\n"
            "• Track your execution — ✅ or ❌, no fluff\n"
            "• Rest with intention, not to escape\n"
            "• Finish before you celebrate\n"
            "• Crush excuses before they take root",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "🪵 This is where the work gets real.\nDiscipline isn’t a feeling — it’s a system.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    } else if (phaseNumber == 3) {
      phaseContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🚀 Phase 3: Progress Over Perfection",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "🧗‍♂️ Take the Step. Stop Waiting.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "This phase is about momentum, not mastery.\n"
            "You’ll silence perfectionism, embrace imperfect action, and keep climbing — even when it’s messy.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚠️ Why It Matters",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Perfection is the enemy of progress.\n"
            "You don’t need flawless days — you need forward motion. This phase teaches you to move anyway.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚙️ What You’ll Do",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "• Finish before you feel ready\n"
            "• Log real wins — even the small ones\n"
            "• Act today, not “tomorrow”\n"
            "• Bounce back fast from failure\n"
            "• Fall in love with the process, not the end",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "🥾 This is where grit is built.\nYou won’t be perfect — but you will get better.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    } else if (phaseNumber == 4) {
      phaseContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🧘 Phase 4: Inner Freedom",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "🕊️ Master Yourself. Silence the Noise.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "This phase is about becoming unshakable — no longer ruled by urges, distractions, or outside approval.\n"
            "You’ll build clarity, stillness, and strength from within.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚠️ Why It Matters",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "A man ruled by chaos is never free.\n"
            "When you master your emotions and detach from the world’s grip, you unlock a deeper power: self-possession.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚙️ What You’ll Do",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "• Practice solitude without distractions\n"
            "• Reflect daily on your integrity\n"
            "• Pause before reacting to emotion\n"
            "• Own your identity — no more blaming others\n"
            "• Replace inner weakness with strength-building habits",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "🪨 This is where freedom begins.\nStill mind. Strong will. Unshakable soul.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    } else if (phaseNumber == 5) {
      phaseContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🤝 Phase 5: Becoming Useful & Compassionate",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "🌍 Live Beyond Yourself. Lead With Strength.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "This phase is about service, humility, and legacy.\n"
            "You’ll use what you’ve built — not to dominate, but to uplift others with purpose and compassion.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚠️ Why It Matters",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "The highest form of strength is service.\n"
            "Without giving back, even greatness feels hollow. This phase fills your life with meaning that endures.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "⚙️ What You’ll Do",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "• Lighten someone’s load every day\n"
            "• Lead by example, not ego\n"
            "• Own your influence in every room\n"
            "• Celebrate quietly — lift, don’t boast\n"
            "• Reflect weekly: “Who did I help?”",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            "🌱 This is where impact begins.\nStrength becomes legacy. Power becomes purpose.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    } else {
      phaseContent = const Center(child: Text('Preview not available for this phase yet.'));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Phase $phaseNumber Preview')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: phaseContent,
              ),
            ),
            const SizedBox(height: 20),
            if (unlocked)
              ElevatedButton(
                onPressed: () => _startPhase(context),
                child: const Text("Start This Phase"),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
