import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/logger_service.dart';
import 'core/storage/local_storage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.instance.init();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, st) {
    // Almost always means `flutterfire configure` hasn't been run yet —
    // see README "Getting Started". Logged instead of crashing so the
    // rest of the app (and this message) is still visible during setup.
    logger.error(
      'Firebase failed to initialize — did you run `flutterfire configure`? See README.md.',
      e,
      st,
    );
  }

  runApp(const SignageSurgeonTechnicianApp());
}
