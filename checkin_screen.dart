import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/checkin_data.dart';
import 'dart:convert';


class CheckInScreen extends StatefulWidget {
  final int phase;

  const CheckInScreen({super.key, required this.phase});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool habit1 = false;
  bool habit2 = false;
  bool habit3 = false;
  int streak = 0;
  int day = 0;
  final TextEditingController journalTextController = TextEditingController();

  List<Map<String, dynamic>> get currentPhaseCheckIns =>
      checkInContentByPhase[widget.phase] ?? [];

  Map<String, dynamic> get todayCheckIn =>
      currentPhaseCheckIns[day % currentPhaseCheckIns.length];

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt('phase${widget.phase}Streak') ?? 0;
      day = prefs.getInt('phase${widget.phase}Day') ?? 0;
    });
  }
@override
  void dispose() {
    journalTextController.dispose(); // 🔁 Required cleanup
    super.dispose();
  }
  Future<void> submitCheckIn() async {
    final prefs = await SharedPreferences.getInstance();

    if (habit1 && habit2 && habit3) {
      streak++;
      await prefs.setInt('phase${widget.phase}Streak', streak);
      await prefs.setInt('phase${widget.phase}Day', day + 1);
    } else {
      streak = 0;
      await prefs.setInt('phase${widget.phase}Streak', 0);
    }
    
    final currentPhase = prefs.getInt('currentPhase') ?? 1;
    final today = DateTime.now().toIso8601String();

    final journalEntry = {
      'date': today,
      'phase': currentPhase,
      'response': journalTextController.text, // ← whatever field you're using
    };

    final existingEntries = prefs.getStringList('journalEntries') ?? [];
    existingEntries.add(jsonEncode(journalEntry));

await prefs.setStringList('journalEntries', existingEntries);

    // Optional: Save journal entry
    String entry = journalTextController.text.trim();
    if (entry.isNotEmpty) {
      List<String> entries =
          prefs.getStringList('phase${widget.phase}Journal') ?? [];
      entries.add(entry);
      await prefs.setStringList('phase${widget.phase}Journal', entries);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Check-In")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("Phase ${widget.phase} — Day ${day + 1}",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(todayCheckIn['prompt'],
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: Text(todayCheckIn['habit1']),
              value: habit1,
              onChanged: (val) => setState(() => habit1 = val!),
            ),
            CheckboxListTile(
              title: Text(todayCheckIn['habit2']),
              value: habit2,
              onChanged: (val) => setState(() => habit2 = val!),
            ),
            CheckboxListTile(
              title: Text(todayCheckIn['habit3']),
              value: habit3,
              onChanged: (val) => setState(() => habit3 = val!),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: journalTextController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: todayCheckIn['prompt'],
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text("Current Streak: $streak / 14",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: submitCheckIn,
              child: const Text("Submit Check-In"),
            ),
          ],
        ),
      ),
    );
  }
}
