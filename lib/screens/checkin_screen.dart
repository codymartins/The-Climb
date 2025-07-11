import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/checkin_data.dart';
import 'dart:convert';

class CheckInScreen extends StatefulWidget {
  final int phase;

  const CheckInScreen({super.key, required this.phase});

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

  // Get today's item for each type
  Map<String, dynamic> getTodayItem(String type) {
    final list = phaseData[type] ?? [];
    if (list.isEmpty) return {};
    if (type == 'longform') {
      // Show every 3rd day (day 2, 5, 8, ...)
      if (day % 3 != 2) return {};
      return list[(day ~/ 3) % list.length];
    }
    return list[day % list.length];
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
      'items': answeredItems,
    };

    final existingEntries = prefs.getStringList('journalEntries') ?? [];
    existingEntries.add(jsonEncode(journalEntry));
    await prefs.setStringList('journalEntries', existingEntries);

    // Update streak and day as before...
    if (answeredItems.length == types.where((t) {
      final item = getTodayItem(t);
      final inputType = item['inputType'];
      return inputType == 'text' || inputType == 'longText' || inputType == 'number';
    }).length) {
      streak++;
      await prefs.setInt('phase${widget.phase}Streak', streak);
      await prefs.setInt('phase${widget.phase}Day', day + 1);
      await prefs.setString(
        'phase${widget.phase}LastCheckIn',
        today,
      );
    } else {
      streak = 0;
      await prefs.setInt('phase${widget.phase}Streak', 0);
    }

    Navigator.pop(context);
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
      ),
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
              "Phase ${widget.phase} — Day ${day + 1}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            buildCheckInButton('challenge', challenge, const Color.fromARGB(255, 79, 98, 113), Icons.flag),
            buildCheckInButton('action', action, const Color.fromARGB(255, 116, 149, 85), Icons.check_circle),
            buildCheckInButton('reflection', reflection, const Color.fromARGB(255, 134, 102, 183), Icons.self_improvement),
            if (showLongform && longform != null && longform.isNotEmpty)
              buildCheckInButton('longform', longform, const Color.fromARGB(255, 95, 155, 149), Icons.edit_note),
            const SizedBox(height: 24),
            Text(
              "Current Streak: $streak / 14",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
