import 'package:flutter/material.dart';
import 'package:note_app/core/presentation/auth/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';
import 'package:note_app/core/presentation/pages/favorites_page/favorites_page_provider.dart';
import 'package:note_app/core/presentation/pages/archive_page/archive_page_provider.dart';
import 'package:note_app/core/presentation/pages/add_note_page/note_detail_page_provider.dart';
import 'l10n/app_localizations.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HelperProvider()),
        ChangeNotifierProvider(create: (_) => HomePageProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesPageProvider()),
        ChangeNotifierProvider(create: (_) => ArchivePageProvider()),
        ChangeNotifierProvider(create: (_) => NoteDetailPageProvider()),
      ],
      child: const NoteApp(),
    ),
  );
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final helperProvider = Provider.of<HelperProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: helperProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: helperProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('km'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: WelcomePage(),
    );
  }
}
