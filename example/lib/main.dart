import 'dart:async';
import 'package:console_plus_example/test2.dart';
import 'package:flutter/material.dart';
import 'package:console_plus/console_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  // ✅ Start logging only after UI is built
  WidgetsBinding.instance.addPostFrameCallback((_) {
    startTimer();
  });
}

void startTimer() {
  Timer.periodic(const Duration(seconds: 2), (timer) {
    final now = DateTime.now();
    DebugLogConsole.log("⏱ Timer Log: $now"); // ✅ Safe: now UI exists
    DebugLogConsole.log("1276 $now"); // ✅ Safe: now UI exists
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext tcontext) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("ConsolePlus Timer Logs")),
        body: Builder(
          builder: (innerContext) => InkWell(
            onTap: () {
              Navigator.push(
                innerContext, // ✅ Use context INSIDE MaterialApp
                MaterialPageRoute(builder: (context) => const Test2()),
              );
            },
            child: const Center(child: Text("Tap the 🐞 button to view logs")),
          ),
        ),
        floatingActionButton: Builder(
          builder: (innerContext) {
            return FloatingActionButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FloatingDebugButton.show(innerContext);
                });
              },
              // ✅ Opens Console
              child: const Icon(Icons.bug_report),
            );
          },
        ),
      ),
    );
  }
}
