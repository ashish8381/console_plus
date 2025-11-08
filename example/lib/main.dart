import 'package:flutter/material.dart';
import 'package:console_plus/console_plus.dart';

void main() {
  runApp(const ConsolePlusExampleApp());
}

class ConsolePlusExampleApp extends StatelessWidget {
  const ConsolePlusExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConsolePlus Example',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  int counter = 0;

  @override
  void initState() {
    super.initState();
    // Show floating debug button when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FloatingDebugButton.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ConsolePlus Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Button pressed $counter times"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                counter++;
                DebugLogConsole.log("Info log #$counter", type: LogType.info);
                DebugLogConsole.log("Warning log #$counter", type: LogType.warning);
                DebugLogConsole.log("Error log #$counter", type: LogType.error);
                setState(() {});
              },
              child: const Text("Generate Logs"),
            ),
          ],
        ),
      ),
    );
  }
}
