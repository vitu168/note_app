import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web platform not configured.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWbkRm8r82El7jexgLQgYZqzq6rFX0Ly8',
    appId: '1:872122524548:android:17af46fee76e7bcf2eb3d1',
    messagingSenderId: '872122524548',
    projectId: 'noteapp-2c062',
    storageBucket: 'noteapp-2c062.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0SYE9_SMOC6-pUv-SYlmDbAiGwBB-D7I',
    appId: '1:872122524548:ios:cadd88288d40416b2eb3d1',
    messagingSenderId: '872122524548',
    projectId: 'noteapp-2c062',
    storageBucket: 'noteapp-2c062.firebasestorage.app',
    iosBundleId: 'com.langvitu.noteApp',
  );
}
