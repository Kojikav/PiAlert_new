import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzht3CESdx8qOOSZMqHDH1IPxECwn6vco',
    appId: '1:936862822711:android:dd9e85c83eedb157a76ab2',
    messagingSenderId: '936862822711',
    projectId: 'kerimzon-b57bc',
    storageBucket: 'kerimzon-b57bc.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBK5zLjnz-tJcsUMEohaUk1NXsVwX0EKMo',
    appId: '1:936862822711:ios:601fc759382ff328a76ab2',
    messagingSenderId: '936862822711',
    projectId: 'kerimzon-b57bc',
    storageBucket: 'kerimzon-b57bc.firebasestorage.app',
    iosBundleId: 'com.pialert.pialert',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9Vep9DF-Rcteb0uP-bKrfqvx3qkO1hbo',
    appId: '1:936862822711:web:f75ad7885f807eb7a76ab2',
    messagingSenderId: '936862822711',
    projectId: 'kerimzon-b57bc',
    authDomain: 'kerimzon-b57bc.firebaseapp.com',
    storageBucket: 'kerimzon-b57bc.firebasestorage.app',
    measurementId: 'G-18HNGV58QX',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBK5zLjnz-tJcsUMEohaUk1NXsVwX0EKMo',
    appId: '1:936862822711:ios:601fc759382ff328a76ab2',
    messagingSenderId: '936862822711',
    projectId: 'kerimzon-b57bc',
    storageBucket: 'kerimzon-b57bc.firebasestorage.app',
    iosBundleId: 'com.pialert.pialert',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD9Vep9DF-Rcteb0uP-bKrfqvx3qkO1hbo',
    appId: '1:936862822711:web:68aa2cf0570dac6aa76ab2',
    messagingSenderId: '936862822711',
    projectId: 'kerimzon-b57bc',
    authDomain: 'kerimzon-b57bc.firebaseapp.com',
    storageBucket: 'kerimzon-b57bc.firebasestorage.app',
    measurementId: 'G-RSSLG9HV9P',
  );
}
