// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7Zbqn2avUz-iKBGj5OvkxcqihayoOEtY',
    appId: '1:885378539534:web:b319efce9c18eeb9029c5f',
    messagingSenderId: '885378539534',
    projectId: 'khe-dev-app-530a8',
    authDomain: 'khe-dev-app-530a8.firebaseapp.com',
    storageBucket: 'khe-dev-app-530a8.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvQcnkP4bPziJaQdSMlJj5jKk_YxXVSVY',
    appId: '1:885378539534:android:e58acb782e0bd6bf029c5f',
    messagingSenderId: '885378539534',
    projectId: 'khe-dev-app-530a8',
    storageBucket: 'khe-dev-app-530a8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRAdX4CfpQGB7LRXK7FGnHpSH7vdHsSbA',
    appId: '1:885378539534:ios:2eacd6a498f353ff029c5f',
    messagingSenderId: '885378539534',
    projectId: 'khe-dev-app-530a8',
    storageBucket: 'khe-dev-app-530a8.appspot.com',
    iosBundleId: 'com.example.socialType',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBRAdX4CfpQGB7LRXK7FGnHpSH7vdHsSbA',
    appId: '1:885378539534:ios:4e19ff405a9ebba9029c5f',
    messagingSenderId: '885378539534',
    projectId: 'khe-dev-app-530a8',
    storageBucket: 'khe-dev-app-530a8.appspot.com',
    iosBundleId: 'com.example.socialType.RunnerTests',
  );
}
