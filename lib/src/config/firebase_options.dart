import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class ScopedFirebaseOptions {
  static String _generateUnsupportedErrorMsgFrom(String platform) =>
      'ScopedFirebaseOptions have not been configured for $platform - '
      'you can reconfigure this by running the FlutterFire CLI again.';

  static FirebaseOptions getCurrentPlatformOn(Environment env) {
    if (kIsWeb) {
      throw UnsupportedError(_generateUnsupportedErrorMsgFrom('web'));
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return env._androidOptions;
      case TargetPlatform.iOS:
        return env._iosOptions;
      case TargetPlatform.macOS:
        throw UnsupportedError(_generateUnsupportedErrorMsgFrom('macOS'));
      case TargetPlatform.windows:
        throw UnsupportedError(_generateUnsupportedErrorMsgFrom('windows'));
      case TargetPlatform.linux:
        throw UnsupportedError(_generateUnsupportedErrorMsgFrom('linux'));
      default:
        throw UnsupportedError(_generateUnsupportedErrorMsgFrom('unknown platform'));
    }
  }
}

class Environment {
  Environment.real()
      : _androidOptions = const FirebaseOptions(
          apiKey: 'AIzaSyBxSnl1ZyvKAOQL3lJcm4onPfYEsVxtgLA',
          appId: '1:415183436199:android:402fa5128144c4a5c41e82',
          messagingSenderId: '415183436199',
          projectId: 'npc-tat',
          databaseURL: 'https://npc-tat.firebaseio.com',
          storageBucket: 'npc-tat.appspot.com',
        ),
        _iosOptions = const FirebaseOptions(
          apiKey: 'AIzaSyBf9Isg0TsB5f2dHv7SsiEQL7ngecySKgc',
          appId: '1:415183436199:ios:f6f04f3a260fb4eac41e82',
          messagingSenderId: '415183436199',
          projectId: 'npc-tat',
          databaseURL: 'https://npc-tat.firebaseio.com',
          storageBucket: 'npc-tat.appspot.com',
          androidClientId: '415183436199-0see1465jui108g6dih3s3hp873bmif4.apps.googleusercontent.com',
          iosClientId: '415183436199-12i4vh39q723gdovbk3fjc0vuvbu1377.apps.googleusercontent.com',
          iosBundleId: 'com.npc.tatFlutter',
        );

  Environment.beta()
      : _androidOptions = const FirebaseOptions(
          apiKey: 'AIzaSyCqHTNBb_JzZh9HIL_1yYcn81Ub8woAcHI',
          appId: '1:866921004681:android:ea333c8e3e552591aad058',
          messagingSenderId: '866921004681',
          projectId: 'npc-tat-beta',
          storageBucket: 'npc-tat-beta.appspot.com',
        ),
        _iosOptions = const FirebaseOptions(
          apiKey: 'AIzaSyDLwnggSSMu1i2aeIKKulu9_A0mwAFdV3Y',
          appId: '1:866921004681:ios:57f386abcab87f2eaad058',
          messagingSenderId: '866921004681',
          projectId: 'npc-tat-beta',
          storageBucket: 'npc-tat-beta.appspot.com',
          iosClientId: '866921004681-oocjb5tk8r9s0df3nn0k57snm2alm3jo.apps.googleusercontent.com',
          iosBundleId: 'com.npc.tatFlutter',
        );

  final FirebaseOptions _androidOptions;
  final FirebaseOptions _iosOptions;
}
