// lib/firebase_options.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reads Firebase credentials from the .env file so you never hardcode secrets.
// Fill in the FIREBASE_* keys in .env — see the key names below.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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

  // ── Android ────────────────────────────────────────────────────────────────
  // .env keys: FIREBASE_ANDROID_API_KEY, FIREBASE_ANDROID_APP_ID,
  //            FIREBASE_PROJECT_ID, FIREBASE_MESSAGING_SENDER_ID,
  //            FIREBASE_STORAGE_BUCKET
  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
      );

  // ── iOS ────────────────────────────────────────────────────────────────────
  // .env keys: FIREBASE_IOS_API_KEY, FIREBASE_IOS_APP_ID,
  //            FIREBASE_IOS_BUNDLE_ID, FIREBASE_PROJECT_ID,
  //            FIREBASE_MESSAGING_SENDER_ID, FIREBASE_STORAGE_BUCKET
  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '',
      );

  // ── Web (optional) ─────────────────────────────────────────────────────────
  // .env keys: FIREBASE_WEB_API_KEY, FIREBASE_WEB_APP_ID,
  //            FIREBASE_PROJECT_ID, FIREBASE_MESSAGING_SENDER_ID,
  //            FIREBASE_STORAGE_BUCKET
  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
        authDomain: '${dotenv.env['FIREBASE_PROJECT_ID'] ?? 'placeholder'}.firebaseapp.com',
      );
}
