import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/resource_library.dart';

class InteractiveSummaryScreen extends StatefulWidget {
  final String summaryId;

  const InteractiveSummaryScreen({super.key, required this.summaryId});

  @override
  _InteractiveSummaryScreenState createState() => _InteractiveSummaryScreenState();
}

class _InteractiveSummaryScreenState extends State<InteractiveSummaryScreen> {
  final PageController _pageController = PageController();
  Map<int, Map<int, int?>> selectedQuizAnswers = {}; // sectionIndex -> quizIndex -> selectedOption
  Map<int, String> reflectionResponses = {}; // sectionIndex -> response
  String finalReflectionResponse = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final summary = interactiveSummaries[widget.summaryId];
    final List<dynamic> sections = summary?['sections'] as List<dynamic>? ?? [];

    setState(() {
      for (int sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
        selectedQuizAnswers[sectionIndex] = {};
        final section = sections[sectionIndex] as Map<String, dynamic>;
        final List<dynamic> quiz = section['quiz'] as List<dynamic>? ?? [];
        for (int quizIndex = 0; quizIndex < quiz.length; quizIndex++) {
          final answer = prefs.getInt('${widget.summaryId}_section$sectionIndex_quiz$quizIndex');
          selectedQuizAnswers[sectionIndex]![quizIndex] = answer;
        }
        final response = prefs.getString('${widget.summaryId}_section$sectionIndex_reflection');
        if (response != null) {
          reflectionResponses[sectionIndex] = response;
        }
      }
      final finalResponse = prefs.getString('${widget.summaryId}_finalReflection');
      if (finalResponse != null) {
        finalReflectionResponse = finalResponse;
      }
      isLoading = false;
    });
  }

  Future<void> _saveQuizAnswer(int sectionIndex, int quizIndex, int? answer) async {
    final prefs = await SharedPreferences.getInstance();
    if (answer != null) {
      await prefs.setInt('${widget.summaryId}_section$sectionIndex_quiz$quizIndex', answer);
    } else {
      await prefs.remove('${widget.summaryId}_section$sectionIndex_quiz$quizIndex');
    }
  }

  Future<void> _saveReflection(int sectionIndex, String response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.summaryId}_section$sectionIndex_reflection', response);
  }

  Future<void> _saveFinalReflection(String response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.summaryId}_finalReflection', response);
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
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        itemCount: sections.length + (finalReflectionPrompt != null ? 1 : 0),
        itemBuilder: (context, pageIndex) {
          if (pageIndex < sections.length) {
            final Map<String, dynamic> section = sections[pageIndex] as Map<String, dynamic>;
            final String sectionTitle = section['title'] as String? ?? 'Untitled Section';
            final String sectionContent = section['content'] as String? ?? '';
            final String? reflectionPrompt = section['reflectionPrompt'] as String?;
            final List<dynamic> quiz = section['quiz'] as List<dynamic>? ?? [];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Author: $author'),
                  Text('Time Estimate: $timeEstimate'),
                  const SizedBox(height: 8),
                  Text(sectionContent),
                  const SizedBox(height: 16),
                  if (reflectionPrompt != null) ...[
                    Text(
                      'Reflection Prompt',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(reflectionPrompt),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Your Response',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      controller: TextEditingController(text: reflectionResponses[pageIndex] ?? ''),
                      onChanged: (value) {
                        reflectionResponses[pageIndex] = value;
                        _saveReflection(pageIndex, value);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (quiz.isNotEmpty) ...[
                    Text(
                      'Quiz',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...quiz.asMap().entries.map((quizEntry) {
                      final Map<String, dynamic> quizItem = quizEntry.value as Map<String, dynamic>;
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
                                });
                                _saveQuizAnswer(pageIndex, quizEntry.key, value);
                                if (value == correctIndex) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Correct!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Try again!')),
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
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        if (pageIndex < sections.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pop(context); // Return to ReferenceLibraryScreen
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(pageIndex < sections.length - 1 ? 'Next' : 'Submit'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Final reflection page
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Final Reflection',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(finalReflectionPrompt!),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Your Response',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    controller: TextEditingController(text: finalReflectionResponse),
                    onChanged: (value) {
                      finalReflectionResponse = value;
                      _saveFinalReflection(value);
                    },
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
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
    super.dispose();
  }
}