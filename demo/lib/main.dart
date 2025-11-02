import 'dart:async';
import 'package:flutter/material.dart';
import 'package:console_plus/console_plus.dart';

Timer? _timer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  // ✅ Start logging only after UI is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    startTimer();
  });
}

void startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
    final now = DateTime.now();
    print("⏱ Timer Log: $now"); // ✅ Logs in Android Studio
    DebugLogConsole.log("⏱ Timer Log: $now"); // ✅ Safe: now UI exists
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("ConsolePlus Timer Logs")),
        body: const Center(child: Text("Tap the 🐞 button to view logs")),
        floatingActionButton: Builder(
          builder: (innerContext) {
            return FloatingActionButton(
              onPressed: () => DebugLogConsole.show(innerContext), // ✅ Opens Console
              child: const Icon(Icons.bug_report),
            );
          }
        ),
      ),
    );
  }
}
