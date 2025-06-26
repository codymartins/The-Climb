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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journal History")),
      body: ListView.builder(
        itemCount: journalEntries.length,
        itemBuilder: (context, index) {
          final entry = journalEntries[index];
          final date = DateTime.parse(entry['date']).toLocal();
          final response = entry['response'];
          final phase = entry['phase'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text("Phase $phase • ${date.toString().split(' ').first}"),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Text(
                    response != null && response.toString().trim().isNotEmpty
                        ? response.toString()
                        : "No journal entry recorded.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
