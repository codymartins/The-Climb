import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/resource_library.dart';
import 'interactive_summary_screen.dart';

class ReferenceLibraryScreen extends StatefulWidget {
  const ReferenceLibraryScreen({super.key});

  @override
  State<ReferenceLibraryScreen> createState() => _ReferenceLibraryScreenState();
}

class _ReferenceLibraryScreenState extends State<ReferenceLibraryScreen> {
  int? currentPhase;

  @override
  void initState() {
    super.initState();
    _loadCurrentPhase();
  }

  Future<void> _loadCurrentPhase() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPhase = prefs.getInt('currentPhase') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentPhase == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final phaseKey = 'phase$currentPhase';
    final phaseSummaries = interactiveSummaries[phaseKey] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Reference Library')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: phaseSummaries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = phaseSummaries.entries.elementAt(index);
          final summary = entry.value;
          return Card(
            child: FutureBuilder<bool>(
              future: isPacketComplete(entry.key),
              builder: (context, snapshot) {
                final isComplete = snapshot.data == true;
                return ListTile(
                  title: Text(summary['title'] as String? ?? 'Untitled'),
                  subtitle: Text('By ${summary['author'] ?? 'Unknown'}'),
                  trailing: isComplete
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InteractiveSummaryScreen(summaryId: entry.key),
                      ),
                    ).then((_) {
                      (context as Element).markNeedsBuild(); // Forces rebuild
                    });
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
  final completedPackets = prefs.getStringList('completedPackets') ?? [];
  return completedPackets.contains(summaryId);
}