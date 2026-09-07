// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not supported.');
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCWAIIIBMZCTiUxFL8xr6TU5OYhHZ0V1qI',
    appId: '1:455173571371:web:52bb26e63072acf40d3b6e',
    messagingSenderId: '455173571371',
    projectId: 'rendhome-7ffd3',
    authDomain: 'rendhome-7ffd3.firebaseapp.com',
    storageBucket: 'rendhome-7ffd3.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWAIIIBMZCTiUxFL8xr6TU5OYhHZ0V1qI',
    appId: '1:455173571371:android:46102b20fcc674250d3b6e',
    messagingSenderId: '455173571371',
    projectId: 'rendhome-7ffd3',
    storageBucket: 'rendhome-7ffd3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWAIIIBMZCTiUxFL8xr6TU5OYhHZ0V1qI',
    appId: '1:455173571371:ios:e11e9560d313756f0d3b6e',
    messagingSenderId: '455173571371',
    projectId: 'rendhome-7ffd3',
    storageBucket: 'rendhome-7ffd3.firebasestorage.app',
    iosClientId:
        '455173571371-ena0vemsjuf918locd5at9g83c0rsin2.apps.googleusercontent.com',
    iosBundleId: 'com.example.rendhoe',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWAIIIBMZCTiUxFL8xr6TU5OYhHZ0V1qI',
    appId: '1:455173571371:ios:e11e9560d313756f0d3b6e',
    messagingSenderId: '455173571371',
    projectId: 'rendhome-7ffd3',
    storageBucket: 'rendhome-7ffd3.firebasestorage.app',
    iosClientId:
        '455173571371-ena0vemsjuf918locd5at9g83c0rsin2.apps.googleusercontent.com',
    iosBundleId: 'com.example.rendhoe',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCWAIIIBMZCTiUxFL8xr6TU5OYhHZ0V1qI',
    appId: '1:455173571371:web:c4d0664047b5485b0d3b6e',
    messagingSenderId: '455173571371',
    projectId: 'rendhome-7ffd3',
    authDomain: 'rendhome-7ffd3.firebaseapp.com',
    storageBucket: 'rendhome-7ffd3.firebasestorage.app',
  );
}
