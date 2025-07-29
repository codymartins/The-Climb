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

    final phaseKey = 'phase${currentPhase ?? 1}';
    final phaseSummaries = interactiveSummaries[phaseKey] ?? {};


    return Scaffold(
      appBar: AppBar(title: const Text('Reference Library')),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.only(top: 200, left: 16, right: 16, bottom: 16), // <-- Increased top padding
            itemCount: phaseSummaries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = phaseSummaries.entries.elementAt(index);
              final summary = entry.value;
              if (summary['title'] == null || summary['title'].toString().trim().isEmpty) {
                return const SizedBox.shrink();
              }
              final summaryId = entry.key;
              return Card(
                child: FutureBuilder<bool>(
                  future: isPacketComplete(summaryId),
                  builder: (context, snapshot) {
                    final isComplete = snapshot.data == true;
                    return ListTile(
                      title: Text(summary['title'] as String? ?? 'Untitled'),
                      subtitle: Text('By ${summary['author'] ?? 'Unknown'}'),
                      trailing: isComplete
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InteractiveSummaryScreen(
                              phaseKey: phaseKey,
                              summaryId: summaryId,
                            ),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            top: 16,
            left: 24,
            right: 24,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Icon(Icons.read_more, color: Colors.green, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "These packets will introduce you to valuable media resources.\nComplete seven to continue to the next phase, and explore them further to continue improving.",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> isPacketComplete(String summaryId) async {
  final prefs = await SharedPreferences.getInstance();
  final completedPackets = prefs.getStringList('completedPackets') ?? [];
  return completedPackets.contains(summaryId);
}
