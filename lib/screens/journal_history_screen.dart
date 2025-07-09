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

  // Customize these offsets to match your background path!
  final Map<int, Offset> phasePositions = {
    1: const Offset(160, 460),
    2: const Offset(70, 355),
    3: const Offset(220, 240),
    4: const Offset(110, 150),
    5: const Offset(175, 40),
  };

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
      final phase = entry['phase'] ?? 1;
      grouped.putIfAbsent(phase, () => []).add(entry);
    }
    return grouped;
  }

  void _showPhaseEntries(BuildContext context, int phase, List<Map<String, dynamic>> entries) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Phase $phase Journal Entries",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(
                          child: Text(
                            "No journal entries for this phase.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: entries.length,
                          itemBuilder: (context, idx) {
                            final entry = entries[idx];
                            final date = DateTime.parse(entry['date']).toLocal();
                            final items = entry['items'] as List<dynamic>? ?? [];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, MMM d').format(date),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    ...items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['prompt'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            item['response']?.toString() ?? '',
                                            style: const TextStyle(color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupEntriesByPhase(journalEntries);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Climb: Journal Timeline")),
      body: Stack(
        children: [
          // Background image with weaving path
          Positioned.fill(
            child: Image.asset(
              'assets/your_weaving_path.png', // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
          // Phase buttons positioned along the path
          ...phasePositions.entries.map((entry) {
            final phase = entry.key;
            final pos = entry.value;
            final entries = grouped[phase] ?? [];
            final isCompleted = entries.isNotEmpty;

            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: GestureDetector(
                onTap: () => _showPhaseEntries(context, phase, entries),
                child: Container(
                  width: 72,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.grey[200] : Colors.blueGrey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.brown,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Notebook "spine" on the left
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.brown[400],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      // Phase label and number
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Phase',
                              style: TextStyle(
                                color: Colors.brown[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$phase',
                              style: TextStyle(
                                color: Colors.brown[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              );
          }),
          // (Optional) Draw lines between the buttons if you want to overlay a line
          // CustomPaint(
          //   painter: TimelinePainter(phasePositions),
          // ),
        ],
      ),
    );
  }
}

// (Optional) Custom painter for connecting lines, if not using a background image with a path
class TimelinePainter extends CustomPainter {
  final Map<int, Offset> positions;
  TimelinePainter(this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[200]!
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < positions.length; i++) {
      final from = positions[i]!;
      final to = positions[i + 1]!;
      canvas.drawLine(
        Offset(from.dx + 32, from.dy + 32), // center of button
        Offset(to.dx + 32, to.dy + 32),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Place this extension OUTSIDE the class!
extension DateTimeExtension on DateTime {
  int get dayOfYear => int.parse(DateFormat("D").format(this));
}
