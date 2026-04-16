import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/presentation/pages/chat_page/chat_page.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page.dart';
import 'package:note_app/core/presentation/pages/setting_page/settings_page.dart';
import 'package:note_app/core/presentation/pages/add_note_page/add_note_page.dart';
import 'package:note_app/core/theme/app_theme.dart';
import 'package:note_app/core/presentation/components/menu_navigation/menu_navigation.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final helperProvider = Provider.of<HelperProvider>(context);
    return MaterialApp(
      theme: AppTheme.lightThemeFor(helperProvider.primaryColor),
      darkTheme: AppTheme.darkThemeFor(helperProvider.primaryColor),
      themeMode: helperProvider.themeMode,
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

  @override
  void initState() {
    super.initState();
    // Ensure the backend user profile exists (no-op for guests)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().syncOnLogin();
    });
  }

  late final List<Widget> _pages = [
    HomePage(onSettingsPressed: () => _onItemTapped(2)),
    const ChatPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabTapped() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddNotePage()),
    );
    if (created == true && context.mounted) {
      context.read<HomePageProvider>().loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: MenuDrawer(selectedIndex: _selectedIndex, onItemSelected: _onItemTapped),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        onFabTapped: _onFabTapped,
      ),
    );
  }
}
