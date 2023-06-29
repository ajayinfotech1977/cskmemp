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
    apiKey: 'AIzaSyDdlYLEzafuSfWWU4Hs2T3PAiWkoFCVH8M',
    appId: '1:535237646147:web:9b2aa84e0345f40faf41f6',
    messagingSenderId: '535237646147',
    projectId: 'cskm-emp',
    authDomain: 'cskm-emp.firebaseapp.com',
    storageBucket: 'cskm-emp.appspot.com',
    measurementId: 'G-MGQVEPCC19',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3qi_7U6QSKC0NWu-aT3QTMANF9t3NXRs',
    appId: '1:535237646147:android:8c23dc9394ffe422af41f6',
    messagingSenderId: '535237646147',
    projectId: 'cskm-emp',
    storageBucket: 'cskm-emp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2YjmKTI1DfvI7OFvciSHt4zWXK8FhEYc',
    appId: '1:535237646147:ios:922a6abb4fbd63a6af41f6',
    messagingSenderId: '535237646147',
    projectId: 'cskm-emp',
    storageBucket: 'cskm-emp.appspot.com',
    iosBundleId: 'cskm.com.cskmemp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2YjmKTI1DfvI7OFvciSHt4zWXK8FhEYc',
    appId: '1:535237646147:ios:065abd046c6bd463af41f6',
    messagingSenderId: '535237646147',
    projectId: 'cskm-emp',
    storageBucket: 'cskm-emp.appspot.com',
    iosBundleId: 'cskm.com.cskmemp.RunnerTests',
  );
}