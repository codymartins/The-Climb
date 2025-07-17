import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  List<Map<String, dynamic>> journalEntries = [];

    Map<String, dynamic> calculateJournalStats(List<Map<String, dynamic>> entries) {
      final stopWords = {
        'the', 'and', 'to', 'of', 'in', 'a', 'is', 'it', 'for', 'on',
        'with', 'at', 'by', 'an', 'be', 'this', 'that', 'i', 'you', 'but', 'my', 'was', 'he', 'she', 'they', 'we', 'me', 'him', 'her', 'them',
      };

      int totalWordCount = 0;
      final Map<String, int> wordFrequency = {};

      for (final entry in entries) {
        final items = entry['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final response = (item['response'] ?? '').toString().toLowerCase();
          final words = response.replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'));

          totalWordCount += words.length;

          for (var word in words) {
            if (word.isNotEmpty && !stopWords.contains(word)) {
              wordFrequency.update(word, (count) => count + 1, ifAbsent: () => 1);
            }
          }
        }
      }

      final mostUsedWord = wordFrequency.entries.isEmpty
          ? 'None'
          : wordFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return {
        'totalEntries': entries.length,
        'averageWords': entries.isEmpty ? 0 : (totalWordCount / entries.length).round(),
        'mostUsedWord': mostUsedWord
      };
    }


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
      final screenHeight = MediaQuery.of(context).size.height;
      final stats = calculateJournalStats(journalEntries);

      return Scaffold(
        appBar: AppBar(title: const Text("Read How You've Grown")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Journal Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Total Entries: ${stats['totalEntries']}"),
                      Text("Average Words per Entry: ${stats['averageWords']}"),
                      Text("Most Used Word: ${stats['mostUsedWord']}"),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OpenJournalView(journalEntries: journalEntries)),
                    );
                  },
                  child: Image.asset(
                    'assets/closed_book.png',
                    height: screenHeight * 0.7,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

//  @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
    
//     return Scaffold(
//       appBar: AppBar(title: const Text("Read How You've Grown")),
//         body: Center(
//   child: GestureDetector(
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => OpenJournalView(journalEntries: journalEntries)),
//       );
//     },
//     child: Image.asset(
//       'assets/closed_book.png',
//       height: screenHeight * 1.8, // About 30% of screen height
//       fit: BoxFit.contain,
//     ),
//   ),
    
  }


class OpenJournalView extends StatelessWidget {
  final List<Map<String, dynamic>> journalEntries;

  const OpenJournalView({super.key, required this.journalEntries});

  Map<int, List<Map<String, dynamic>>> groupEntriesByPhase() {
    final Map<int, List<Map<String, dynamic>>> grouped = {};
    for (final entry in journalEntries) {
      final phase = entry['phase'] ?? 1;
      grouped.putIfAbsent(phase, () => []).add(entry);
    }
    return grouped;
  }



  @override
  Widget build(BuildContext context) {
    final grouped = groupEntriesByPhase();

    return Scaffold(
      appBar: AppBar(title: const Text("Your Journal")),
      body: PageView.builder(
        itemCount: 5,
        controller: PageController(viewportFraction: 0.88),
        itemBuilder: (context, index) {
          return PhaseJournalCard(phase: index + 1, entries: grouped[index + 1] ?? []);
        },
      ),
    );
  }
}

class PhaseJournalCard extends StatelessWidget {
  final int phase;
  final List<Map<String, dynamic>> entries;

  const PhaseJournalCard({super.key, required this.phase, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        color: Colors.brown[50],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Phase $phase", style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text("No journal entries yet."))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, idx) {
                        final entry = entries[idx];
                        final date = DateTime.parse(entry['date']).toLocal();
                        final items = entry['items'] as List<dynamic>? ?? [];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('EEEE, MMM d').format(date),
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ...items.map((item) => Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['prompt'] ?? '',
                                                style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Text(item['response'] ?? ''),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Place this extension OUTSIDE the class!
extension DateTimeExtension on DateTime {
  int get dayOfYear => int.parse(DateFormat("D").format(this));
}
