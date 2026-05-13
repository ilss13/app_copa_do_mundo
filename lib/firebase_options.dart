// IMPORTANTE: Este arquivo é um stub. Execute `flutterfire configure` para
// gerar os valores reais de configuração do Firebase.
// Instale a CLI: `dart pub global activate flutterfire_cli`
// Depois execute: `flutterfire configure`
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Plataforma não suportada');
    }
  }

  // TODO: Substitua pelos valores reais após `flutterfire configure`
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCH5BWec0tls4dE9JsdXONJR2uxVGZTDok',
    appId: '1:599934575252:android:1ed93acec48fc514d68a81',
    messagingSenderId: '599934575252',
    projectId: 'copa-do-mundo-d050b',
    storageBucket: 'copa-do-mundo-d050b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.copa.mundo.world.cup',
  );
}
