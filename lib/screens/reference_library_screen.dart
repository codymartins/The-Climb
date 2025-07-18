import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/resource_library.dart';
import 'interactive_summary_screen.dart';

class ReferenceLibraryScreen extends StatelessWidget {
  const ReferenceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reference Library')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: interactiveSummaries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = interactiveSummaries.entries.elementAt(index);
          final summary = entry.value;
          return Card(
            child: FutureBuilder<bool>(
              future: isPacketComplete(entry.key),
              builder: (context, snapshot) {
                final isComplete = snapshot.data == true;
                return ListTile(
                  title: Text(summary['title']as String? ?? 'Untitled'),
                  subtitle: Text('By ${summary['author'] ?? 'Unknown'}'),
                  trailing: isComplete ? Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InteractiveSummaryScreen(summaryId: entry.key),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

Future<bool> isPacketComplete(String summaryId) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('${summaryId}_responses');
  if (raw == null) return false;
  final data = jsonDecode(raw);
  final quizAnswers = data['quizAnswers'] as Map;
  final summary = interactiveSummaries[summaryId];
  if (summary == null) return false;
  final sections = summary['sections'] as List<dynamic>? ?? [];
  for (int i = 0; i < sections.length; i++) {
    final quiz = (sections[i]['quiz'] as List<dynamic>? ?? []);
    for (int j = 0; j < quiz.length; j++) {
      final correctIndex = quiz[j]['correctIndex'];
      final userAnswer = quizAnswers['$i']?['$j'];
      if (userAnswer == null || userAnswer != correctIndex) return false;
    }
  }
  return true;
}