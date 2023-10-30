import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:stravadegarschaud/pages/auth_gate_page.dart';
import 'firebase_options.dart';

import 'pages/home_page.dart';
import 'models/app_model.dart';
import 'common/brosse_autosaver.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider()
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    // Put page in running mode if the brosse wasn't stopped manually.
    final model = AppModel();
    if(BrosseAutosaver.wasRunning) model.toggleRunning();

    return ChangeNotifierProvider(
      create: (context) => model,
      child: MaterialApp(
        title: "Strava de gars chaud",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const AuthGate(), // Go to AuthGate to verify if user is logged in or not
      ),
    );
  }
}