// =============================================================================
// PLACEHOLDER — DO NOT USE IN PRODUCTION
// =============================================================================
//
// This file is a placeholder for the auto-generated `firebase_options.dart`.
//
// To generate the real file:
//   1. Install the FlutterFire CLI:
//        dart pub global activate flutterfire_cli
//   2. Run:
//        flutterfire configure
//   3. Replace this file with the generated `firebase_options.dart`.
//
// NEVER hardcode API keys. Use --dart-define or .env for secrets.
// ==========================================================================
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:my_meds/core/config/env_config.dart'; // adapte le chemin vers ton EnvConfig

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => FirebaseOptions(
    apiKey: EnvConfig.firebaseApiKey,
    appId: EnvConfig.firebaseAppId,
    messagingSenderId: EnvConfig.firebaseMessagingSenderId,
    projectId: EnvConfig.firebaseProjectId,
  );
}
