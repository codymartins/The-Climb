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

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sections.length + (finalReflectionPrompt != null ? 1 : 0),
        itemBuilder: (context, pageIndex) {
          if (pageIndex < sections.length) {
            final section = sections[pageIndex] as Map<String, dynamic>;
            final String sectionTitle = section['title'] as String? ?? 'Untitled Section';
            final String sectionContent = section['content'] as String? ?? '';
            final String? reflectionPrompt = section['reflectionPrompt'] as String?;
            final List<dynamic> quiz = section['quiz'] as List<dynamic>? ?? [];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView( // <-- Add this wrapper
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sectionTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Author: $author'),
                    Text('Time Estimate: $timeEstimate'),
                    const SizedBox(height: 8),
                    Text(sectionContent),
                    const SizedBox(height: 16),
                    if (reflectionPrompt != null) ...[
                      Text('Reflection Prompt', style: Theme.of(context).textTheme.titleMedium),
                      Text(reflectionPrompt),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Your Response',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        controller: reflectionControllers[pageIndex],
                        onChanged: (value) {
                          reflectionResponses[pageIndex] = value;
                          _saveAllResponses();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (quiz.isNotEmpty) ...[
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
                                        duration: const Duration(milliseconds: 700), // <-- Shorter duration
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
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          if (pageIndex < sections.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else if (finalReflectionPrompt != null && pageIndex == sections.length - 1) {
                            // Go to final reflection page
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            // If already on final reflection, submit
                            markPacketComplete();
                            Navigator.pop(context);
                          }
                        },
                        child: Text(pageIndex < sections.length - 1 ? 'Next' : 'Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Final reflection page
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Final Reflection', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(finalReflectionPrompt!),
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
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        markPacketComplete();
                        Navigator.pop(context);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            );
          }
        },
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