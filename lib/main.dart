import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Uncomment the lines below after running `flutterfire configure`:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:my_meds/core/config/firebase_options_placeholder.dart';

import 'package:my_meds/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load environment variables ──
  await dotenv.load(fileName: '.env');

  // ── Initialize Firebase ──
  // Uncomment after running `flutterfire configure`:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // ── Launch app with Riverpod ──
  runApp(
    const ProviderScope(
      child: MyMedsApp(),
    ),
  );
}
