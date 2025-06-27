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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isDone = completedTitles.contains(item['title']);
            return GestureDetector(
              onTap: () => openLink(item['url']!),
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(item['title'] ?? ''),
                    content: Text(
                      item['description'] ?? 'No description available.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                color: isDone ? Colors.green[50] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          item['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        item['type'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: Icon(
                            isDone
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isDone ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => toggleCompleted(item['title']!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
