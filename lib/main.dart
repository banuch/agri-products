import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'state/language_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final language = LanguageController();
  await language.load();

  Object? firebaseError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    firebaseError = e;
  }

  runApp(firebaseError == null
      ? AgriSocietyApp(language: language)
      : SetupRequiredApp(error: firebaseError));
}
