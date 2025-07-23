import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ViceCategory {
  final String name;
  final IconData icon;
  int streak;
  List<Map<String, dynamic>> history;
  ViceCategory({
    required this.name,
    required this.icon,
    this.streak = 0,
    List<Map<String, dynamic>>? history,
  }) : history = history ?? [];
}

class ViceTrackerPage extends StatefulWidget {
  const ViceTrackerPage({super.key});

  @override
  State<ViceTrackerPage> createState() => _ViceTrackerPageState();
}

class _ViceTrackerPageState extends State<ViceTrackerPage> {
  final List<ViceCategory> categories = [
    ViceCategory(name: "Distraction", icon: Icons.phone_android),
    ViceCategory(name: "Indulgence", icon: Icons.fastfood),
    ViceCategory(name: "Avoidance", icon: Icons.block),
    ViceCategory(name: "Anger", icon: Icons.mood_bad),
    ViceCategory(name: "Other", icon: Icons.help),
  ];

  Map<String, List<Map<String, String>>> shuffledAdvice = {};
  Map<String, int> currentAdviceIndex = {};

    void _showCategoryPicker() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("What are you struggling with?"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: adviceLibrary.keys.map((category) {
                return ListTile(
                  title: Text(category),
                  onTap: () => Navigator.pop(context, category),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      if (!mounted) return;
      _showNextShuffledAdvice(context, selected);
    }
  }
    void _showNextShuffledAdvice(BuildContext context, String category) {
    final original = adviceLibrary[category];

    if (original == null || original.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No advice found for this category.")),
      );
      return;
    }

    if (!shuffledAdvice.containsKey(category)) {
      final shuffled = List<Map<String, String>>.from(original)..shuffle();
      shuffledAdvice[category] = shuffled;
      currentAdviceIndex[category] = 0;
    }

    final idx = currentAdviceIndex[category]!;
    final quote = shuffledAdvice[category]![idx];
    currentAdviceIndex[category] = (idx + 1) % shuffledAdvice[category]!.length;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('"${quote['quote']}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("- ${quote['author']}", style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Text(quote['explanation'] ?? ''),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }


  void _checkIn(ViceCategory category, bool clean) async {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    final alreadyChecked = category.history.any((h) => h['date'] == todayStr);

    if (alreadyChecked) return;

    String? detail;
    if (!clean) {
      detail = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: Text("How did you fall short today?"),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Required",
                hintText: "e.g. Instagram, Netflix, Chips, Avoided call, etc.",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
      if (detail == null || detail.isEmpty) {
        return; // User cancelled or didn't enter anything
      }
    }

    setState(() {
      if (clean) {
        category.streak += 1;
        category.history.add({'date': todayStr, 'clean': true, 'detail': ''});
      } else {
        category.streak = 0;
        category.history.add({
          'date': todayStr,
          'clean': false,
          'detail': detail ?? '',
        });
      }
    });
    await saveCategories(); // <-- Add this line
  }

  Widget _buildCategoryTile(ViceCategory category) {
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";
    final todayEntry = category.history
        .where((h) => h['date'] == todayStr)
        .toList();

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(category.icon, size: 32, color: const Color.fromARGB(255, 135, 212, 248)),
            const SizedBox(width: 12),
            Text(
              category.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  "🔥 Streak: ${category.streak} days",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (category.streak % 30) / 30,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          if (todayEntry.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Check-In:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text("Stayed Clean"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _checkIn(category, true),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text("Slipped Up"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => _checkIn(category, false),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                todayEntry.first['clean']
                    ? "✅ Stayed clean today"
                    : "❌ Slipped up: ${todayEntry.first['detail']}",
                style: TextStyle(
                  color: todayEntry.first['clean'] ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (category.history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ExpansionTile(
                title: const Text(
                  "History",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                children: category.history.reversed.map((entry) {
                  return ListTile(
                    title: Text(entry['date']),
                    subtitle: entry['clean']
                        ? const Text("Stayed clean")
                        : Text("Slipped up: ${entry['detail']}"),
                    trailing: entry['clean']
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.close, color: Colors.red),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> saveCategories() async {
  final prefs = await SharedPreferences.getInstance();
  for (final category in categories) {
    await prefs.setInt('${category.name}_streak', category.streak);
    await prefs.setStringList(
      '${category.name}_history',
      category.history.map((h) => jsonEncode(h)).toList(),
    );
  }
}

Future<void> loadCategories() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    for (final category in categories) {
      category.streak = prefs.getInt('${category.name}_streak') ?? 0;
      final historyRaw = prefs.getStringList('${category.name}_history') ?? [];
      category.history = historyRaw.map((h) => jsonDecode(h) as Map<String, dynamic>).toList();
    }
  });
}

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stay Accountable")),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny, color: const Color.fromARGB(255, 252, 206, 91), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Each afternoon, check in with yourself. Did you do the right things? If not, reflect on your choices and build your resolve for tomorrow.",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...categories.map(_buildCategoryTile),    

                   Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: _showCategoryPicker,
            icon: CircleAvatar(
              radius: 24, // Larger bust icon
              backgroundImage: const AssetImage('assets/marcus_bust.png'),
              backgroundColor: Colors.transparent
            ),
            label: const Text(
              "Ask a Pro",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(220, 64), // Larger button
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ),     
        ],
      ),     
    );
  }
}

final Map<String, List<Map<String, String>>> adviceLibrary = {
  "Distraction": [
    {
      'quote': "You must not allow yourself to dwell for a single moment on any kind of weakness.",
      'author': "Epictetus",
      'explanation': "When distraction pulls you, respond by focusing on one small deliberate action."
    },
    {
      'quote': "It is not that we have a short time to live, but that we waste much of it.",
      'author': "Seneca",
      'explanation': "Use your time intentionally. Every moment spent distracted is a moment lost forever."
    },
    {
      'quote': "You have power over your mind—not outside events. Realize this, and you will find strength.",
      'author': "Marcus Aurelius",
      'explanation': "You control your focus. External noise only distracts if you let it."
    },
    {
      'quote': "The impediment to action advances action. What stands in the way becomes the way.",
      'author': "Marcus Aurelius",
      'explanation': "Use distractions as opportunities to practice discipline. Turn obstacles into stepping stones."
    },
    {
      'quote': "Beware the barrenness of a busy life.",
      'author': "Socrates",
      'explanation': "Being active doesn’t mean you’re moving forward. Prioritize what matters."
    },
    {
      'quote': "The things you think about determine the quality of your mind.",
      'author': "Marcus Aurelius",
      'explanation': "Guard your thoughts. Focus on what builds you up, not what pulls you down."
    },
    {
      'quote': "Waste no more time arguing about what a good person should be. Be one.",
      'author': "Marcus Aurelius",
      'explanation': "Stop debating distractions. Just take action towards your goals."
    }
  ],
  "Indulgence": [
    {
      'quote': "Self-control is strength. Right thought is mastery.",
      'author': "James Allen",
      'explanation': "Recognize urges as passing. Master yourself rather than becoming a slave to desire."
    },
    {
      'quote': "The greatest wealth is to live content with little.",
      'author': "Plato",    
      'explanation': "True fulfillment comes from within, not from external pleasures. Seek simplicity."
    },
    {
      'quote': "Pleasure is the bait of sin.",
      'author': "Seneca",
      'explanation': "Indulgence may seem sweet, but it leads to deeper cravings. Resist the bait."
    }, 
    {
      'quote': "The best revenge is to be unlike him who performed the injury.",
      'author': "Marcus Aurelius",
      'explanation': "Don’t let indulgence define you. Rise above it and cultivate your own virtue."
    },
    {
      'quote': "Do not spoil what you have by desiring what you have not.",
      'author': "Epicurus",
      'explanation': "Gratitude for what you have is the antidote to endless craving."
    },
    {
      'quote': "The mind is everything. What you think, you become.",
      'author': "Buddha",
      'explanation': "Focus on building a strong mind. Indulgence weakens your resolve."
    },
    {
      'quote': "He who conquers himself is the mightiest warrior.",
      'author': "Confucius",
      'explanation': "Victory over indulgence is the greatest triumph of all."
    },
    {
      'quote': "No man is free who is not master of himself.",
      'author': "Epictetus",
      'explanation': "Freedom comes from self-discipline. Don’t let indulgence chain you."
    }
  ],
  "Avoidance": [
    {
      'quote': "The only way to deal with fear is to face it head on.",
      'author': "Seneca",
      'explanation': "Avoidance only strengthens fear. Confront what you dread."
    },
    {
      'quote': "What stands in the way becomes the way.",
      'author': "Marcus Aurelius",
      'explanation': "Obstacles are opportunities for growth. Embrace them."
    },
    {
      'quote': "Do not be afraid to give up the good to go for the great.",
      'author': "John D. Rockefeller",
      'explanation': "Avoiding discomfort keeps you from achieving greatness."
    },
    {
      'quote': "The greatest weapon against stress is our ability to choose one thought over another.",
      'author': "William James",
      'explanation': "You control your response. Don’t let avoidance dictate your choices."
    },
    {
      'quote': "Courage is not the absence of fear, but the triumph over it.",
      'author': "Nelson Mandela",
      'explanation': "Facing avoidance takes courage, but it leads to true freedom."
    },
    {
      'quote': "The only thing we have to fear is fear itself.",
      'author': "Franklin D. Roosevelt",
      'explanation': "Fear is an illusion. Don’t let it paralyze you."
    },
  ],
  "Anger": [
    {
      'quote': "Holding onto anger is like drinking poison and expecting the other person to die.",
      'author': "Buddha",
      'explanation': "Anger harms you more than anyone else. Let it go."
    },
    {
      'quote': "The best revenge is to be unlike him who performed the injury.",
      'author': "Marcus Aurelius",
      'explanation': "Rise above anger. Don’t let it define your actions."
    },
    {
      'quote': "Anger is a brief madness.",
      'author': "Horace",
      'explanation': "Recognize anger for what it is—a fleeting emotion that clouds judgment."
    },
    {
      'quote': "Do not let the sun go down while you are still angry.",
      'author': "Ephesians 4:26",
      'explanation': "Resolve conflicts quickly. Don’t let anger fester."
    },
    {
      'quote': "To be angry is to revenge the faults of others on ourselves.",
      'author': "Alexander Pope",
      'explanation': "Anger only harms you. Choose peace instead."
    },
    {
      'quote': "He who angers you conquers you.",
      'author': "Elizabeth Kenny",
      'explanation': "Don’t give others power over your emotions. Stay in control."
    },
  ],
  "Other": [
    {
      'quote': "The unexamined life is not worth living.",
      'author': "Socrates",
      'explanation': "Reflect on your actions. Growth comes from self-awareness."
    },
    {
      'quote': "Knowing yourself is the beginning of all wisdom.",
      'author': "Aristotle",
      'explanation': "Understand your vices to overcome them."
    },
    {
      'quote': "What we fear doing most is usually what we most need to do.",
      'author': "Tim Ferriss",
      'explanation': "Face your fears head-on. They often hold the key to growth."
    },
  ],
  // Add other categories...
};
