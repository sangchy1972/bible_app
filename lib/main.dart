import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KJV Bible',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBibleData();
  }

  Future<void> loadBibleData() async {
    try {
      final String response = await rootBundle.loadString('assets/kjv.json');
      final data = json.decode(response);
      setState(() {
        books = List<Map<String, dynamic>>.from(data['books']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading Bible data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KJV Holy Bible'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text('No books found'))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${book['id']}'),
                      ),
                      title: Text(book['name']),
                      subtitle: Text(
                        '${book['testament'] == 'OT' ? 'Old Testament' : 'New Testament'} • ${book['chapters']} chapters',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChapterListPage(
                              book: book,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class ChapterListPage extends StatelessWidget {
  final Map<String, dynamic> book;

  const ChapterListPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final int chapters = book['chapters'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(book['name']),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: chapters,
        itemBuilder: (context, index) {
          final chapterNum = index + 1;
          return Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerseReadingPage(
                      bookId: book['id'],
                      bookName: book['name'],
                      chapter: chapterNum,
                    ),
                  ),
                );
              },
              child: Center(
                child: Text(
                  '$chapterNum',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class VerseReadingPage extends StatefulWidget {
  final int bookId;
  final String bookName;
  final int chapter;

  const VerseReadingPage({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapter,
  });

  @override
  State<VerseReadingPage> createState() => _VerseReadingPageState();
}

class _VerseReadingPageState extends State<VerseReadingPage> {
  List<String> verses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVerses();
  }

  Future<void> loadVerses() async {
    try {
      final String response = await rootBundle.loadString('assets/kjv.json');
      final data = json.decode(response);
      final versesData = data['verses'] as Map<String, dynamic>;
      
      List<String> loadedVerses = [];
      int verseNum = 1;
      
      while (true) {
        final key = '${widget.bookId}:${widget.chapter}:$verseNum';
        if (versesData.containsKey(key)) {
          loadedVerses.add('${verseNum}. ${versesData[key]}');
          verseNum++;
        } else {
          break;
        }
      }
      
      setState(() {
        verses = loadedVerses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading verses: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookName} ${widget.chapter}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : verses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No verses available for ${widget.bookName} ${widget.chapter}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sample data includes:\n• Genesis 1\n• Matthew 1\n• John 1',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        verses[index],
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    );
                  },
                ),
    );
  }
}
