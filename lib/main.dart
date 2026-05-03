import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:note_app/core/config/supabase_config.dart';
import 'package:note_app/core/presentation/auth/splash_page.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:note_app/core/providers/helper_provider.dart';
import 'package:note_app/core/presentation/pages/home_page/home_page_provider.dart';
import 'package:note_app/core/presentation/pages/chat_page/chat_page_provider.dart';
import 'package:note_app/core/presentation/pages/archive_page/archive_page_provider.dart';
import 'package:note_app/core/presentation/pages/add_note_page/note_detail_page_provider.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'package:note_app/core/services/chat_notification_service.dart';
import 'package:note_app/core/services/reminder_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (_) {}

    await ChatNotificationService.instance.init();
    await ReminderNotificationService.instance.init();
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HelperProvider()),
        ChangeNotifierProvider(create: (_) => HomePageProvider()),
        ChangeNotifierProvider(create: (_) => ChatPageProvider()),
        ChangeNotifierProvider(create: (_) => ArchivePageProvider()),
        ChangeNotifierProvider(create: (_) => NoteDetailPageProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
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
      theme: AppTheme.lightThemeFor(helperProvider.primaryColor),
      darkTheme: AppTheme.darkThemeFor(helperProvider.primaryColor),
      themeMode: helperProvider.themeMode,
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
      home: const SplashPage(),
    );
  }
}
