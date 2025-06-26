import 'package:flutter/material.dart';
import '../data/checkin_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PhasePreviewScreen extends StatelessWidget {
  final int phase;
  final bool unlocked;

  const PhasePreviewScreen({super.key, required this.phase, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final phaseContent = checkInContentByPhase[phase] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Phase $phase Preview")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "Phase $phase — ${unlocked ? 'Unlocked' : 'Locked'}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  if (!unlocked)
                    const Text(
                      "You haven’t unlocked this phase yet. Keep going!",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 20),
                  ...phaseContent.map((entry) => Card(
                    child: ListTile(
                      title: Text(entry['prompt'] ?? ''),
                      subtitle: Text(
                        "${entry['habit1']}\n${entry['habit2']}\n${entry['habit3']}",
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (unlocked)
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('currentPhase', phase);
                  await prefs.setInt('phase${phase}Day', 0); // start at day 1
                  await prefs.setInt('phase${phase}Streak', 0); // optional reset
                  Navigator.pop(context);
                },
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
