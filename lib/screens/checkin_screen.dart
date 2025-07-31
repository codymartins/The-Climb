import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../../data/checkin_data.dart';
import 'dart:convert';

class CheckInScreen extends StatefulWidget {
  final int phase;
  final String period; // 'AM' or 'PM'
  final bool legacyMode; // New parameter

  const CheckInScreen({super.key, required this.phase, required this.period, this.legacyMode = false});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  int streak = 0;
  int day = 0;

  // Store responses by type
  Map<String, dynamic> responses = {};

  Map<String, List<Map<String, dynamic>>> get phaseData =>
      checkInContentByPhase[widget.phase] ?? {};

  // Filter items by period
  Map<String, dynamic> getTodayItem(String type) {
    if (widget.legacyMode) {
      // Combine prompts from all phases
      List<Map<String, dynamic>> allPrompts = [];
      for (var phase in checkInContentByPhase.values) {
        allPrompts.addAll(phase[type] ?? []);
      }
      // Filter by period
      final filtered = allPrompts.where((item) => item['period'] == widget.period).toList();
      if (filtered.isEmpty) return {};
      // For longform, only show every 3rd day and only for PM
      if (type == 'longform') {
        if (day % 3 != 2 || widget.period != 'PM') return {};
        filtered.shuffle();
        return filtered.first;
      }
      filtered.shuffle();
      return filtered.first;
    } else {
      // Normal mode
      final list = phaseData[type] ?? [];
      if (list.isEmpty) return {};
      final filtered = list.where((item) => item['period'] == widget.period).toList();
      if (filtered.isEmpty) return {};
      if (type == 'longform') {
        // Only show longform every 3rd day AND only for PM check-ins
        if (day % 3 != 2 || widget.period != 'PM') return {};
        return filtered[(day ~/ 3) % filtered.length];
      }
      return filtered[day % filtered.length];
    }
  }

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // --- Streak reset logic ---
    final lastCheckInStr = prefs.getString('phase${widget.phase}LastCheckIn');
    if (lastCheckInStr != null) {
      final lastCheckIn = DateTime.parse(lastCheckInStr);
      final now = DateTime.now();
      final lastDate = DateTime(
        lastCheckIn.year,
        lastCheckIn.month,
        lastCheckIn.day,
      );
      final todayDate = DateTime(now.year, now.month, now.day);
      if (todayDate.difference(lastDate).inDays > 1) {
        // Missed a full calendar day, reset streak
        await prefs.setInt('phase${widget.phase}Streak', 0);
      }
    }
    // --- End streak reset logic ---

    setState(() {
      streak = prefs.getInt('phase${widget.phase}Streak') ?? 0;
      day = prefs.getInt('phase${widget.phase}Day') ?? 0;
    });
  }

  Future<void> submitCheckIn() async {
    final prefs = await SharedPreferences.getInstance();

    final types = ['challenge', 'action', 'reflection'];
    if (day % 3 == 2) types.add('longform');

    // Only save written responses (text, longText, number)
    final List<Map<String, dynamic>> answeredItems = [];
    for (final type in types) {
      final item = getTodayItem(type);
      if (item.isEmpty) continue;
      final val = responses[type];
      final inputType = item['inputType'];
      // Only save if it's a written response
      if ((inputType == 'text' || inputType == 'longText' || inputType == 'number') &&
          val != null && val.toString().trim().isNotEmpty) {
        answeredItems.add({
          'type': type,
          'prompt': item['text'],
          'response': val,
          'inputType': inputType,
          'description': item['description'],
        });
      }
    }

    // Save to journal
    final currentPhase = prefs.getInt('currentPhase') ?? widget.phase;
    final today = DateTime.now().toIso8601String();

    final journalEntry = {
      'date': today,
      'phase': currentPhase,
      'period': widget.period,
      'items': answeredItems,
    };

    final existingEntries = prefs.getStringList('journalEntries') ?? [];
    existingEntries.add(jsonEncode(journalEntry));
    await prefs.setStringList('journalEntries', existingEntries);

    // Save AM/PM completion for streak logic
    await prefs.setBool('phase${widget.phase}Day${day}_${widget.period}', true);

    // Check if both AM and PM are done for today
    final amDone = prefs.getBool('phase${widget.phase}Day${day}_AM') ?? false;
    final pmDone = prefs.getBool('phase${widget.phase}Day${day}_PM') ?? false;
    if (amDone && pmDone) {
      streak++;
      await prefs.setInt('phase${widget.phase}Streak', streak);
      await prefs.setInt('phase${widget.phase}Day', day + 1);
      await prefs.setString('phase${widget.phase}LastCheckIn', today);
    }

    // Show animation dialog
    await showMotivationDialog();

    // Wait a moment, then pop both the dialog and the check-in screen
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // Close dialog if still open
    if (Navigator.canPop(context)) Navigator.pop(context); // Pop check-in screen
  }

  final List<String> quotes = [
    "Keep climbing. Your future self needs this.",
    "Small steps compound. Consistency is paramount.",
    "Discipline will grant you freedom.",
    "You are elevating yourself.",
    "Consistency beats intensity.",
    "Every check-in gets you closer.",
    "Progress, not perfection.",
    "Embrace the climb, not just the summit.",
    "The journey is the reward.",
    "Your effort today shapes your tomorrow.",
    "Each day you improve through failure or success.",
    "Believe in the process. Trust your ability to grow.",
    "Discipline is the bridge between goals and accomplishment.",
    "Success is the sum of small efforts repeated day in and day out.",
    "You are building yourself through this effort.",
    "Be who you intend to be.",
    "True failure is ignoring your potential.",
    "Be vigilant. Stay focused.",
    "Life is yours to shape. Make it count.",
    "You are the architect of your own growth.",
  ];

  Future<void> showMotivationDialog() async {
    final controller = ConfettiController(duration: const Duration(seconds: 2));
    controller.play();

    // Pick a random quote
    final quote = (quotes..shuffle()).first;

    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Color.fromARGB(255, 86, 130, 87), Color.fromARGB(255, 78, 110, 135), Color.fromARGB(255, 165, 132, 171), Color.fromARGB(255, 191, 165, 126), Color.fromARGB(255, 148, 102, 118)],
            ),
            Container(
              width: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 250, 248, 248),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center, color: Color.fromARGB(255, 15, 15, 15), size: 50),
                  const SizedBox(height: 16),
                  Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 22, 22, 22),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    // Wait for 2 seconds, then close dialog and check-in screen
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // Close dialog
    if (Navigator.canPop(context)) Navigator.pop(context); // Pop check-in screen

    controller.dispose();
  }

  void showInputModal(String type, Map<String, dynamic> item) {
    final controller = TextEditingController(text: responses[type]?.toString() ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        Widget input;
        switch (item['inputType']) {
          case 'checkbox':
            input = StatefulBuilder(
              builder: (context, setModalState) => CheckboxListTile(
                title: Text(item['text']),
                value: responses[type] ?? false,
                onChanged: (val) {
                  setModalState(() => responses[type] = val);
                  setState(() => responses[type] = val);
                },
              ),
            );
            break;
          case 'number':
            input = TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: item['text'],
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => responses[type] = val,
            );
            break;
          case 'longText':
            input = TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: item['text'],
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => responses[type] = val,
            );
            break;
          case 'multipleChoice':
            input = StatefulBuilder(
              builder: (context, setModalState) {
                final options = item['options'] as List<dynamic>? ?? [];
                final selected = responses[type]?.toString();
                return Column(
                  children: [
                    for (final option in options)
                      RadioListTile<String>(
                        title: Text(option.toString()),
                        value: option.toString(),
                        groupValue: selected,
                        onChanged: (val) {
                          setModalState(() => responses[type] = val);
                          setState(() => responses[type] = val);
                        },
                      ),
                  ],
                );
              },
            );
            break;
          case 'text':
          default:
            input = TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: item['text'],
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => responses[type] = val,
            );
        }
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['text'] ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (item['description'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    item['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              const SizedBox(height: 12),
              input,
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCheckInButton(String type, Map<String, dynamic> item, Color color, IconData icon) {
    final answered = responses[type] != null &&
        ((item['inputType'] == 'checkbox' && responses[type] == true) ||
         (item['inputType'] != 'checkbox' && responses[type].toString().isNotEmpty));
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(type[0].toUpperCase() + type.substring(1)),
        subtitle: answered
            ? const Text("Completed", style: TextStyle(color: Colors.green))
            : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => showInputModal(type, item),
      )
      );

  }

  @override
  Widget build(BuildContext context) {
    final challenge = getTodayItem('challenge');
    final action = getTodayItem('action');
    final reflection = getTodayItem('reflection');
    final showLongform = day % 3 == 2;
    final longform = showLongform ? getTodayItem('longform') : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Check-In")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              widget.legacyMode
                  ? "Legacy Mode — Day ${day + 1}"
                  : "Phase ${widget.phase} — Day ${day + 1}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            buildCheckInButton('challenge', challenge, const Color.fromARGB(255, 79, 98, 113), Icons.flag),
            buildCheckInButton('action', action, const Color.fromARGB(255, 116, 149, 85), Icons.check_circle),
            buildCheckInButton('reflection', reflection, const Color.fromARGB(255, 134, 102, 183), Icons.self_improvement),
            if (showLongform && longform != null && longform.isNotEmpty)
              buildCheckInButton('longform', longform, const Color.fromARGB(255, 95, 155, 149), Icons.edit_note),
            const SizedBox(height: 24),
            if (!widget.legacyMode) ...[
              Text(
                "Current Streak: $streak / 14",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
            ],
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

