import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stravadegarschaud/config_page.dart';

import 'activity_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;

  runApp(const MyApp());
}


final _router = GoRouter(
  initialLocation: '/activity',
  routes: [
    GoRoute(
      path: '/activity',
      builder: (context, state) => const ActivityPage(),
    ),
    GoRoute(
      path: '/config',
      builder: (context, state) => ConfigPage(),
    )
  ]
);

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Strava de gars chaud",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}