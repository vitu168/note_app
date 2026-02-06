import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/presentation/pages/archive_page/archive_page.dart';
import 'package:note_app/core/presentation/pages/favorites_page/favorites_page.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page.dart';
import 'package:note_app/core/presentation/pages/setting_page/settings_page.dart';
import 'package:note_app/core/theme/app_theme.dart';
import 'package:note_app/core/presentation/components/menu_navigation/bottom_navigation.dart';
import 'package:note_app/core/presentation/components/menu_navigation/menu_drawer.dart';
import 'package:note_app/core/providers/helper_provider.dart';

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final helperProvider = Provider.of<HelperProvider>(context);
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: helperProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FavoritesPage(),
    const ArchivePage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // global drawer so menu is available from all pages
      drawer: MenuDrawer(selectedIndex: _selectedIndex, onItemSelected: _onItemTapped),
      // No appBar here!
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
