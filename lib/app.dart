import 'package:flutter/material.dart';
import 'views/root_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manhwa Tracker',
      theme: ThemeData.dark(),
      home: const RootView(),
    );
  }
}
