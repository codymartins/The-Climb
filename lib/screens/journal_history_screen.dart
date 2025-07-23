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
      final stats = calculateJournalStats(journalEntries);
      final sentences = getAllSentences(journalEntries);

      return Scaffold(
        appBar: AppBar(
          title: const Text("Your Journal"),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OpenJournalView(journalEntries: journalEntries)),
                      );
                    },
                    child: Image.asset(
                      'assets/closed_book.png',
                      height: 500, // <-- Fixed height, adjust as needed
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                if (sentences.isNotEmpty)
                  LiveJournalHighlight(sentences: sentences),
                SizedBox(height: 64),
              ],
            ),
            // --- Journal Stats Button in top left of inner screen ---
            Positioned(
              top: 12,
              left: 12,
              child: Material(
                color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor, // Match AppBar
                shape: const CircleBorder(),
                elevation: 6,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Journal Stats"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text("Total Entries: ${stats['totalEntries']}"),
                            Text("Average Words per Entry: ${stats['averageWords']}"),
                            InkWell(
                              onTap: () {
                                final topWords = getTopWords(journalEntries);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Word Cloud"),
                                    content: SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 12,
                                          runSpacing: 4,
                                          children: topWords.entries.map((e) {
                                            final fontSize = 16 + (e.value * 2);
                                            final colors = [
                                              Colors.blue[300],
                                              const Color.fromARGB(255, 138, 29, 240),
                                              const Color.fromARGB(255, 77, 95, 255),
                                              Colors.green[400],
                                              Colors.purple[300],
                                              Colors.teal[300],
                                            ];
                                            final color = colors[e.key.hashCode % colors.length];
                                            final rotation = (e.key.hashCode % 3 - 1) * 0.08;

                                            return Transform.rotate(
                                              angle: rotation,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                                child: Text(
                                                  e.key,
                                                  style: TextStyle(
                                                    fontSize: fontSize.clamp(16, 28).toDouble(),
                                                    fontWeight: FontWeight.bold,
                                                    color: color,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Material(
                                color: const Color.fromARGB(255, 83, 81, 80),
                                borderRadius: BorderRadius.circular(20),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Most Used Word: ${stats['mostUsedWord']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(255, 245, 242, 241),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                          
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.bar_chart,
                      size: 28,
                      color: Colors.white, // White icon
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
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
                                  if (entry['label'] != null)
                                    Text(
                                      entry['label'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                        fontSize: 14,
                                      ),
                                    ),
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

List<String> getAllSentences(List<Map<String, dynamic>> entries) {
  final List<String> sentences = [];
  for (final entry in entries) {
    final items = entry['items'] as List<dynamic>? ?? [];
    for (final item in items) {
      final response = (item['response'] ?? '').toString();
      // Split into sentences by period, exclamation, or question mark
      sentences.addAll(response.split(RegExp(r'[.!?]')).map((s) => s.trim()).where((s) => s.isNotEmpty));
    }
  }
  return sentences;
}

class LiveJournalHighlight extends StatefulWidget {
  final List<String> sentences;
  final Duration displayDuration;
  final Duration typewriterSpeed;

  const LiveJournalHighlight({
    super.key,
    required this.sentences,
    this.displayDuration = const Duration(seconds: 3),
    this.typewriterSpeed = const Duration(milliseconds: 40),
  });

  @override
  State<LiveJournalHighlight> createState() => _LiveJournalHighlightState();
}

class _LiveJournalHighlightState extends State<LiveJournalHighlight> with SingleTickerProviderStateMixin {
  late List<String> shuffledSentences;
  int sentenceIndex = 0;
  String displayedText = "";
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    shuffledSentences = List<String>.from(widget.sentences)..shuffle(); // Shuffle once on init
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _showNextSentence();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _showNextSentence() async {
    if (shuffledSentences.isEmpty) return;
    _fadeController.forward();
    final sentence = shuffledSentences[sentenceIndex % shuffledSentences.length];
    displayedText = "";
    for (int i = 0; i < sentence.length; i++) {
      await Future.delayed(widget.typewriterSpeed);
      setState(() {
        displayedText = sentence.substring(0, i + 1);
      });
    }
    await Future.delayed(widget.displayDuration);
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      sentenceIndex = (sentenceIndex + 1) % shuffledSentences.length;
      displayedText = "";
    });
    _showNextSentence();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 160, 160, 160),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          displayedText.isEmpty ? "" : '“$displayedText”',
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2, // Limit to 2 lines
          overflow: TextOverflow.ellipsis, // Fade out overflow
        ),
      ),
    );
  }
}

Map<String, int> getTopWords(List<Map<String, dynamic>> entries, {int topN = 10}) {
  final stopWords = {
    'the', 'and', 'to', 'of', 'in', 'a', 'is', 'it', 'for', 'on',
    'with', 'at', 'by', 'an', 'be', 'this', 'that', 'i', 'you', 'but', 'my', 'was', 'he', 'she', 'they', 'we', 'me', 'him', 'her', 'them',
  };
  final Map<String, int> wordFrequency = {};
  for (final entry in entries) {
    final items = entry['items'] as List<dynamic>? ?? [];
    for (final item in items) {
      final response = (item['response'] ?? '').toString().toLowerCase();
      final words = response.replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'));
      for (var word in words) {
        if (word.isNotEmpty && !stopWords.contains(word)) {
          wordFrequency.update(word, (count) => count + 1, ifAbsent: () => 1);
        }
      }
    }
  }
  final sorted = wordFrequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return Map.fromEntries(sorted.take(topN));
}
