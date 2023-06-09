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
    apiKey: 'AIzaSyDsW3xSnD0qbYkysuFedFOjO5opSmMV3EE',
    appId: '1:389131875767:web:c14a1042c1befb15426432',
    messagingSenderId: '389131875767',
    projectId: 'welfare-attendance',
    authDomain: 'welfare-attendance.firebaseapp.com',
    storageBucket: 'welfare-attendance.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9D7Scqgs0A5hnE0S56CW0ow_O6qSot6Q',
    appId: '1:389131875767:android:f06f1cc45178e6e8426432',
    messagingSenderId: '389131875767',
    projectId: 'welfare-attendance',
    storageBucket: 'welfare-attendance.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiG3p1oitWHidaDU4pXc9McutJggKQ01U',
    appId: '1:389131875767:ios:bdddf8b488cd5599426432',
    messagingSenderId: '389131875767',
    projectId: 'welfare-attendance',
    storageBucket: 'welfare-attendance.appspot.com',
    iosClientId: '389131875767-bpptfq8ttt249fkpepeg9lhk9ftlf2ed.apps.googleusercontent.com',
    iosBundleId: 'com.example.welfareAttendanceProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDiG3p1oitWHidaDU4pXc9McutJggKQ01U',
    appId: '1:389131875767:ios:dcc3d7f1bce8ddb7426432',
    messagingSenderId: '389131875767',
    projectId: 'welfare-attendance',
    storageBucket: 'welfare-attendance.appspot.com',
    iosClientId: '389131875767-snhcried64mvrtj0h39u1eit4bkrm8rd.apps.googleusercontent.com',
    iosBundleId: 'com.example.welfareAttendanceProject.RunnerTests',
  );
}
