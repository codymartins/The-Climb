import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  List<Map<String, dynamic>> journalEntries = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journalEntries') ?? [];

    final parsed = raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    setState(() {
      journalEntries = parsed.reversed.toList(); // show most recent first
    });
  }

  Map<int, List<Map<String, dynamic>>> groupEntriesByPhase(List<Map<String, dynamic>> entries) {
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (final entry in entries) {
      final phase = entry['phase'] as int;
      grouped.putIfAbsent(phase, () => []).add(entry);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupEntriesByPhase(journalEntries);

    return Scaffold(
      appBar: AppBar(title: const Text("Journal History")),
      body: ListView(
        children: grouped.entries.map((phaseGroup) {
          final phase = phaseGroup.key;
          final entries = phaseGroup.value;

          return ExpansionTile(
            title: Text("Phase $phase"),
            children: entries.map((entry) {
              final date = DateTime.parse(entry['date']).toLocal();
              final response = entry['response'];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(date.toString().split(' ').first),
                  subtitle: Text(
                    response != null && response.toString().trim().isNotEmpty
                        ? response.toString()
                        : "No journal entry recorded.",
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
