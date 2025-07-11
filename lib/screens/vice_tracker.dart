import 'package:flutter/material.dart';

class ViceCategory {
  final String name;
  final IconData icon;
  int streak;
  List<Map<String, dynamic>> history;
  ViceCategory({
    required this.name,
    required this.icon,
    this.streak = 0,
    List<Map<String, dynamic>>? history,
  }) : history = history ?? [];
}

class ViceTrackerPage extends StatefulWidget {
  const ViceTrackerPage({super.key});

  @override
  State<ViceTrackerPage> createState() => _ViceTrackerPageState();
}

class _ViceTrackerPageState extends State<ViceTrackerPage> {
  final List<ViceCategory> categories = [
    ViceCategory(name: "Distraction", icon: Icons.phone_android),
    ViceCategory(name: "Indulgence", icon: Icons.fastfood),
    ViceCategory(name: "Avoidance", icon: Icons.block),
    ViceCategory(name: "Anger", icon: Icons.mood_bad),
    ViceCategory(name: "Other", icon: Icons.help),
  ];

  void _checkIn(ViceCategory category, bool clean) async {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    final alreadyChecked = category.history.any((h) => h['date'] == todayStr);

    if (alreadyChecked) return;

    String? detail;
    if (!clean) {
      detail = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text("How did you fall short today?"),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Required",
                hintText: "e.g. Instagram, Netflix, Chips, Avoided call, etc.",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
      if (detail == null || detail.isEmpty)
        return; // User cancelled or didn't enter anything
    }

    setState(() {
      if (clean) {
        category.streak += 1;
        category.history.add({'date': todayStr, 'clean': true, 'detail': ''});
      } else {
        category.streak = 0;
        category.history.add({
          'date': todayStr,
          'clean': false,
          'detail': detail ?? '',
        });
      }
    });
  }

  Widget _buildCategoryTile(ViceCategory category) {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    final todayEntry = category.history
        .where((h) => h['date'] == todayStr)
        .toList();

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(category.icon, size: 32, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              category.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  "🔥 Streak: ${category.streak} days",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (category.streak % 30) / 30,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          if (todayEntry.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Check-In:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text("Stayed Clean"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _checkIn(category, true),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text("Slipped Up"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => _checkIn(category, false),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                todayEntry.first['clean']
                    ? "✅ Stayed clean today"
                    : "❌ Slipped up: ${todayEntry.first['detail']}",
                style: TextStyle(
                  color: todayEntry.first['clean'] ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (category.history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ExpansionTile(
                title: const Text(
                  "History",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                children: category.history.reversed.map((entry) {
                  return ListTile(
                    title: Text(entry['date']),
                    subtitle: entry['clean']
                        ? const Text("Stayed clean")
                        : Text("Slipped up: ${entry['detail']}"),
                    trailing: entry['clean']
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.close, color: Colors.red),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("💀 Vice Tracker")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Face what holds you back. Track your vices honestly, spot patterns, and reinforce your growth.",
              style: TextStyle(color: Colors.white),

            ),
          ),
          ...categories.map(_buildCategoryTile),
        ],
      ),
    );
  }
}
