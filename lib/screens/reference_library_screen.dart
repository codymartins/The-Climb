// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../data/resource_library.dart';
// import 'package:url_launcher/url_launcher.dart';

// final Map<String, IconData> typeIcons = {
//   'Book': Icons.menu_book,
//   'Podcast': Icons.podcasts,
//   'Video': Icons.ondemand_video,
//   'Article': Icons.article,
//   'Speech': Icons.record_voice_over,
// };





// class ReferenceLibraryScreen extends StatefulWidget {
//   const ReferenceLibraryScreen({super.key});

//   @override
//   State<ReferenceLibraryScreen> createState() => _ReferenceLibraryScreenState();
// }

// int currentPhase = 1;

// class _ReferenceLibraryScreenState extends State<ReferenceLibraryScreen> {
//   Set<String> completedTitles = {};
//   String? selectedSummaryId;

//   Map<String, dynamic> getSummaryById(String id) {
//   return interactiveSummaries[id] ?? {};
// }
//   @override
//   void initState() {
//     super.initState();
//     loadProgress();
//   }

//   Future<void> loadProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     currentPhase = prefs.getInt('currentPhase') ?? 1;

//     final saved = prefs.getStringList('phase${currentPhase}MediaList') ?? [];
//     setState(() {
//       completedTitles = saved.toSet();
//     });
//   }

//   Future<void> toggleCompleted(String title) async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       if (completedTitles.contains(title)) {
//         completedTitles.remove(title);
//       } else {
//         completedTitles.add(title);
//       }
//     });
//     await prefs.setStringList(
//       'phase${currentPhase}MediaList',
//       completedTitles.toList(),
//     );
//     await prefs.setInt('phase${currentPhase}Media', completedTitles.length);
//   }

//   void openLink(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final items = resourceLibrary[currentPhase] ?? [];

//     if (selectedSummaryId != null) {
//           final summary = getSummaryById(selectedSummaryId!);
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(summary['title'] ?? 'Summary', style: Theme.of(context).textTheme.headlineSmall),
//                 const SizedBox(height: 12),
//                 ...?summary['sections']?.map<Widget>((section) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(section['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 8),
//                       Text(section['content']),
//                       const Divider(),
//                     ],
//                   );
//                 }).toList(),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       selectedSummaryId = null; // Go back to grid
//                     });
//                   },
//                   child: const Text("Back to Library"),
//                 ),
//               ],
//             ),
//           );
//         }
      

//     return Scaffold(
//       appBar: AppBar(title: const Text("Reference Library")),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 1.2,
//           ),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             final isDone = completedTitles.contains(item['title']);
//             return GestureDetector(
//               onTap: () {
//                 final isRequired = item['required'] == true;
//                 final summaryId = item['summaryId'] as String?;

//                 setState(() {
//                   if (isRequired && summaryId != null) {
//                     selectedSummaryId = summaryId;
//                   } else {
//                     openLink(item['url'] as String);
//                   }
//                 });
//               },
//               //   setState(() {
//               //     if (item['required'] == true && item['summaryId'] != null) {
//               //       selectedSummaryId = item['summaryId'] as String?;
//               //     } else {
//               //       openLink(item['url']! as String );
//               //     }
//               //   });
//               // },

//               onLongPress: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text(item['title'] as String? ?? ''),
//                     content: Text(
//                       item['description'] as String? ?? 'No description available.',
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text('Close'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 4,
//                 color: isDone ? Colors.green[50] : Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Flexible(
//                         child: Text(
//                           item['title'] as String? ?? '',
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           softWrap: true,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.blue,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         item['type'] as String? ?? '',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black54,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             typeIcons[item['type']] ?? Icons.help_outline,
//                             color: Colors.blue,
//                           ),
//                         ],
//                       ),
//                       Align(
//                         alignment: Alignment.bottomRight,
//                         child: IconButton(
//                           icon: Icon(
//                             isDone
//                                 ? Icons.check_circle
//                                 : Icons.check_circle_outline,
//                             color: isDone ? Colors.green : Colors.grey,
//                           ),
//                           onPressed: () => toggleCompleted(item['title']! as String),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../../data/resource_library.dart';
import 'interactive_summary_screen.dart'; // Adjust import path if needed

class ReferenceLibraryScreen extends StatelessWidget {
  const ReferenceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reference Library'),
        elevation: 4, // Slight shadow for app bar
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the list
        child: ListView.separated(
          itemCount: interactiveSummaries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12), // Space between cards
          itemBuilder: (context, index) {
            final entry = interactiveSummaries.entries.elementAt(index);
            final summary = entry.value;
            final String title = summary['title'] as String? ?? 'Untitled';
            final String author = summary['author'] as String? ?? 'Unknown';
            final String timeEstimate = summary['timeEstimate'] as String? ?? 'N/A';

            return Card(
              elevation: 4, // Shadow for floating effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: InkWell(
                // InkWell for tap feedback
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveSummaryScreen(
                        summaryId: entry.key,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'By $author',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Time: $timeEstimate',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
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