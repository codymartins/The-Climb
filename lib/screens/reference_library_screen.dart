import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/resource_library.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferenceLibraryScreen extends StatefulWidget {
  const ReferenceLibraryScreen({super.key});

  @override
  State<ReferenceLibraryScreen> createState() => _ReferenceLibraryScreenState();
}

int currentPhase = 1;

class _ReferenceLibraryScreenState extends State<ReferenceLibraryScreen> {
  Set<String> completedTitles = {};

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    currentPhase = prefs.getInt('currentPhase') ?? 1;

    final saved = prefs.getStringList('phase${currentPhase}MediaList') ?? [];
    setState(() {
      completedTitles = saved.toSet();
    });
  }

  Future<void> toggleCompleted(String title) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (completedTitles.contains(title)) {
        completedTitles.remove(title);
      } else {
        completedTitles.add(title);
      }
    });
    await prefs.setStringList(
      'phase${currentPhase}MediaList',
      completedTitles.toList(),
    );
    await prefs.setInt('phase${currentPhase}Media', completedTitles.length);
  }

  void openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = resourceLibrary[currentPhase] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Reference Library")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isDone = completedTitles.contains(item['title']);
          return ListTile(
            title: GestureDetector(
              onTap: () => openLink(item['url']!),
              child: Text(
                item['title'] ?? '',
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            subtitle: Text(item['type'] ?? ''),
            trailing: IconButton(
              icon: Icon(
                isDone ? Icons.check_circle : Icons.check_circle_outline,
                color: isDone ? Colors.green : Colors.grey,
              ),
              onPressed: () => toggleCompleted(item['title']!),
            ),
          );
        },
      ),
    );
  }
}
