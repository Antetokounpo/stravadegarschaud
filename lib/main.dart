import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'home_page.dart';
import 'app_model.dart';
import 'brosse_autosaver.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;

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
        home: HomePage(),
      ),
    );
  }
}