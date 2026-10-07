import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration.
///
/// Loads values from `.env` file or `--dart-define` at build time.
class EnvConfig {
  EnvConfig._();

  /// Initialize dotenv. Call before runApp().
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env file might not exist in production/CI, fallback to --dart-define
    }
  }

  /// Example accessor — replace with your own keys.
  static String get firebaseApiKey {
    const fromEnv = String.fromEnvironment('FIREBASE_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.maybeGet('FIREBASE_API_KEY') ?? '';
  }

  static String get firebaseAppId {
    const fromEnv = String.fromEnvironment('FIREBASE_APP_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.maybeGet('FIREBASE_APP_ID') ?? '';
  }

  static String get firebaseMessagingSenderId {
    const fromEnv = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.maybeGet('FIREBASE_MESSAGING_SENDER_ID') ?? '';
  }

  static String get firebaseProjectId {
    const fromEnv = String.fromEnvironment('FIREBASE_PROJECT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.maybeGet('FIREBASE_PROJECT_ID') ?? '';
  }
}
