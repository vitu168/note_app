import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/presentation/pages/archive_page/archive_page.dart';
import 'package:note_app/core/presentation/pages/favorites_page/favorites_page.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page.dart';
import 'package:note_app/core/presentation/pages/setting_page/settings_page.dart';
import 'package:note_app/core/theme/app_theme.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:note_app/l10n/app_localizations.dart';

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
      // No appBar here!
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: AppLocalizations.of(context).home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_rounded),
                label: AppLocalizations.of(context).favorites,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive_rounded),
                label: AppLocalizations.of(context).archive,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: AppLocalizations.of(context).settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
