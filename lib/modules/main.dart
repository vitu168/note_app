import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'appcolor.dart' as Colors;
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://atmmyhssaafgascfoikm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0bW15aHNzYWFmZ2FzY2ZvaWttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMTAxNjEsImV4cCI6MjA2MDg4NjE2MX0.G6wJKDINQbzFONYIFvIcyUVHn9Uzs9u1Haae5CnOC5s',
  );
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primaryColor: Colors.info,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.info,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: HomePage(),
    );
  }
}
