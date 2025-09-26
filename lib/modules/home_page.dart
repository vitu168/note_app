import 'package:flutter/material.dart';
import 'package:note_app/model/model.dart';
import 'add_page.dart';
import 'appcolor.dart' as Colors;
import 'package:note_app/db/database_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Model> notes = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    try {
      final fetchedNotes = await _dbHelper.readAllNotes();
      setState(() {
        notes = fetchedNotes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notes: $e')),
      );
    }
  }

  void _navigateToAddPage({Model? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPage(note: note)),
    ).then((_) => _refreshNotes());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FavoritePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: notes.isEmpty
          ? Center(child: Text('No Notes yet. Add one!'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.title ?? 'unitetled'),
                  subtitle: Text(formatdate(note.date ?? '')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          note.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: note.isFavorite ? Colors.error : null,
                        ),
                        onPressed: () async {
                          try {
                            // Placeholder: Toggle favorite status
                            // note.isFavourite = !note.isFavourite;
                            // await _dbHelper.update(note);
                            _refreshNotes();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error updating favorite: $e')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          try {
                            // Placeholder: Delete note
                            // await _dbHelper.delete(note.id!);
                            _refreshNotes();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Note Deleted')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error Deletting note: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => _navigateToAddPage(note: note),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPage(),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
