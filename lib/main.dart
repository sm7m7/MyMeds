import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:my_meds/app.dart';
import 'package:my_meds/core/config/env_config.dart';
import 'package:my_meds/core/config/firebase_options_placeholder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('CHECKPOINT 1: binding ok');

  await EnvConfig.init();
  debugPrint('CHECKPOINT 2: env ok, projectId=${EnvConfig.firebaseProjectId}');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('CHECKPOINT 3: firebase ok');

  runApp(const ProviderScope(child: MyMedsApp()));
  debugPrint('CHECKPOINT 4: runApp called');
}
