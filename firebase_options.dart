import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      apiKey: "AIzaSyDcXaYcMrtXuD_pGbxdXj2Rppkcu2RhqmM",
      authDomain: "prenew-ee834.firebaseapp.com",
      projectId: "prenew-ee834",
      storageBucket: "prenew-ee834.appspot.com",
      messagingSenderId: "969804879673",
      appId: "1:969804879673:web:dd3f404d7ad9d76567fae8",
      measurementId: "G-KPEPZM49BK");

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKBGMtLcN1FYs6YkrxwxmsoT1JhJE7Spc',
    appId: '1:969804879673:android:107fe90728fdeddd67fae8',
    messagingSenderId: '969804879673',
    projectId: 'prenew-ee834',
    storageBucket: 'prenew-ee834.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDeJas2SWyWxVBo4Z4PrRrQQra5ra6iIOY',
    appId: '1:969804879673:ios:c4afc13ae42277fe67fae8',
    messagingSenderId: '969804879673',
    projectId: 'prenew-ee834',
    storageBucket: 'prenew-ee834.appspot.com',
    iosBundleId: 'com.prestige.prenew',
  );
}
