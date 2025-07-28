import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/resource_library.dart';

class InteractiveSummaryScreen extends StatefulWidget {
  final String summaryId;
  const InteractiveSummaryScreen({super.key, required this.summaryId});

  @override
  State<InteractiveSummaryScreen> createState() => _InteractiveSummaryScreenState();
}

class _InteractiveSummaryScreenState extends State<InteractiveSummaryScreen> {
  final PageController _pageController = PageController();
  Map<int, Map<int, int?>> selectedQuizAnswers = {};
  Map<int, String> reflectionResponses = {};
  String finalReflectionResponse = '';
  bool isLoading = true;
  List<TextEditingController> reflectionControllers = [];
  TextEditingController finalReflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadResponses();
    // Initialize controllers after loading responses
    final summary = interactiveSummaries[widget.summaryId];
    final sections = summary?['sections'] as List<dynamic>? ?? [];
    reflectionControllers = List.generate(
      sections.length,
      (i) => TextEditingController(text: reflectionResponses[i] ?? ''),
    );
  }

  Future<void> _loadResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${widget.summaryId}_responses');
    if (raw != null) {
      final data = jsonDecode(raw);
      selectedQuizAnswers = (data["quizAnswers"] as Map).map(
        (k, v) => MapEntry(int.parse(k), Map<int, int?>.from(v as Map)),
      );
      reflectionResponses = (data["reflections"] as Map).map(
        (k, v) => MapEntry(int.parse(k), v as String),
      );
      finalReflectionResponse = data["finalReflection"] ?? '';
      // Update controllers with loaded text
      for (int i = 0; i < reflectionControllers.length; i++) {
        reflectionControllers[i].text = reflectionResponses[i] ?? '';
      }
      finalReflectionController.text = finalReflectionResponse;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveAllResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      "quizAnswers": selectedQuizAnswers,
      "reflections": reflectionResponses,
      "finalReflection": finalReflectionResponse,
    };
    await prefs.setString('${widget.summaryId}_responses', jsonEncode(data));
  }

  Future<void> markPacketComplete() async {
    final prefs = await SharedPreferences.getInstance();
    // Only increment if not already counted
    final completedPackets = prefs.getStringList('completedPackets') ?? [];
    if (!completedPackets.contains(widget.summaryId)) {
      completedPackets.add(widget.summaryId);
      await prefs.setStringList('completedPackets', completedPackets);
      // Increment mediaCount
      final currentPhase = prefs.getInt('currentPhase') ?? 1;
      final mediaKey = 'phase${currentPhase}Media';
      final mediaCount = prefs.getInt(mediaKey) ?? 0;
      await prefs.setInt(mediaKey, mediaCount + 1);
    }
  }

  Future<void> saveReflectionsToJournal() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPhase = prefs.getInt('currentPhase') ?? 1;
    final now = DateTime.now().toIso8601String();

    // Prepare entries for each reflection
    List<Map<String, dynamic>> newEntries = [];

    final summary = interactiveSummaries[widget.summaryId];
    final String summaryTitle = summary?['title'] as String? ?? 'Packet';

    final List<dynamic> sections = summary?['sections'] as List<dynamic>? ?? [];
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i] as Map<String, dynamic>;
      final String? reflectionPrompt = section['reflectionPrompt'] as String?;
      final String response = reflectionResponses[i] ?? '';
      if (reflectionPrompt != null && response.trim().isNotEmpty) {
        newEntries.add({
          'date': now,
          'phase': currentPhase,
          'label': summaryTitle,
          'items': [
            {
              'prompt': reflectionPrompt,
              'response': response,
            }
          ],
        });
      }
    }
    // Final reflection
    final String? finalReflectionPrompt = summary?['finalReflectionPrompt'] as String?;
    if (finalReflectionPrompt != null && finalReflectionResponse.trim().isNotEmpty) {
      newEntries.add({
        'date': now,
        'phase': currentPhase,
        'label': summaryTitle,
        'items': [
          {
            'prompt': finalReflectionPrompt,
            'response': finalReflectionResponse,
          }
        ],
      });
    }

    // Save to journalEntries
    final raw = prefs.getStringList('journalEntries') ?? [];
    final updated = List<String>.from(raw)..addAll(newEntries.map((e) => jsonEncode(e)));
    await prefs.setStringList('journalEntries', updated);
  }

  @override
  Widget build(BuildContext context) {
    final summary = interactiveSummaries[widget.summaryId];
    if (summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Summary not found')),
      );
    }

    final String title = summary['title'] as String? ?? 'Summary';
    final String author = summary['author'] as String? ?? 'Unknown';
    final String timeEstimate = summary['timeEstimate'] as String? ?? 'N/A';
    final List<dynamic> sections = summary['sections'] as List<dynamic>? ?? [];
    final String? finalReflectionPrompt = summary['finalReflectionPrompt'] as String?;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    int totalPages = sections.length + (finalReflectionPrompt != null ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StatefulBuilder(
          builder: (context, setState) {

            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalPages,
                    itemBuilder: (context, pageIndex) {
                      if (pageIndex < sections.length) {
                        final section = sections[pageIndex] as Map<String, dynamic>;
                        final String sectionTitle = section['title'] as String? ?? 'Untitled Section';
                        final String sectionContent = section['content'] as String? ?? '';
                        final String? reflectionPrompt = section['reflectionPrompt'] as String?;
                        final List<dynamic> quiz = section['quiz'] as List<dynamic>? ?? [];

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Introduction Card
                              Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sectionTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('Author: $author'),
                                      Text('Time Estimate: $timeEstimate'),
                                      const SizedBox(height: 8),
                                      Text(sectionContent),
                                    ],
                                  ),
                                ),
                              ),
                              // Reflection Prompt Card
                              if (reflectionPrompt != null)
                                Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  color: Theme.of(context).cardColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Reflection Prompt', style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 8),
                                        Text(reflectionPrompt),
                                        const SizedBox(height: 8),
                                        TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'Your Response',
                                            border: OutlineInputBorder(),
                                          ),
                                          maxLines: 3,
                                          controller: reflectionControllers[pageIndex],
                                          onChanged: (value) {
                                            reflectionResponses[pageIndex] = value;
                                            _saveAllResponses();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Quiz Card
                              if (quiz.isNotEmpty)
                                Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  color: Theme.of(context).cardColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Quiz', style: Theme.of(context).textTheme.titleMedium),
                                        ...quiz.asMap().entries.map((quizEntry) {
                                          final quizItem = quizEntry.value as Map<String, dynamic>;
                                          final String question = quizItem['question'] as String? ?? 'Question';
                                          final List<dynamic> options = quizItem['options'] as List<dynamic>? ?? [];
                                          final int correctIndex = quizItem['correctIndex'] as int? ?? 0;

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(question),
                                              ...options.asMap().entries.map((optionEntry) {
                                                final int optionIndex = optionEntry.key;
                                                final String option = optionEntry.value as String? ?? '';
                                                return RadioListTile<int>(
                                                  title: Text(option),
                                                  value: optionIndex,
                                                  groupValue: selectedQuizAnswers[pageIndex]?[quizEntry.key],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedQuizAnswers[pageIndex] ??= {};
                                                      selectedQuizAnswers[pageIndex]![quizEntry.key] = value;
                                                      _saveAllResponses();
                                                    });
                                                    if (value == correctIndex) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(value == correctIndex ? 'Correct!' : 'Try again!'),
                                                          duration: const Duration(milliseconds: 700),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                );
                                              }),
                                              const SizedBox(height: 8),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else {
                        // Final Reflection Page
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Final Reflection', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(finalReflectionPrompt ?? ''),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Your Response',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                    controller: finalReflectionController,
                                    onChanged: (value) {
                                      finalReflectionResponse = value;
                                      _saveAllResponses();
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (context) {
                        int currentPage = _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;
                        if (currentPage < totalPages - 1) {
                          return ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            
                            child: const Text('Next'),
                          );
                        } else {
                          // On the final page, show Submit Packet button
                          return ElevatedButton(
                            onPressed: () async {
                              await markPacketComplete();
                              await saveReflectionsToJournal(); // Save reflections to journal
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Submit Packet'),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose controllers
    for (var controller in reflectionControllers) {
      controller.dispose();
    }
    finalReflectionController.dispose(); // Dispose this too
    super.dispose();
  }
}