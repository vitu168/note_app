import 'package:flutter/material.dart';
import 'package:note_app/core/presentation/pages/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HelperProvider()),
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
