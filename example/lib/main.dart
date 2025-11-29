import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:console_plus/console_plus.dart';

Future<void> main() async {
  // ✅ Initialize & run app inside ConsolePlus zone
  await ConsolePlus.initApp(
    const ConsolePlusExampleApp(),
    interceptPrints: true,
    captureFlutterErrors: true,
    capturePlatformErrors: true,
  );
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
    // Show Console floating debug button when the app starts
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
              onPressed: () async {
                const totalLogs = 300; // number of logs to generate
                const logSize =
                    50000; // each log = ~500 KB (adjust up to 1_000_000 for 1MB)
                const delay = Duration(
                  milliseconds: 50,
                ); // small pause between logs

                debugPrint(
                  "🚀 Starting large log stress test: $totalLogs logs, $logSize bytes each",
                );

                final largeChunk =
                    'X' * logSize; // prebuild one large string to reuse

                for (int i = 0; i < totalLogs; i++) {
                  final message = "🔥 MASSIVE LOG #$i\n$largeChunk";

                  // Alternate between print & debugPrint
                  if (i.isEven) {
                    if (kDebugMode) {
                      print(message);
                    }
                  } else {
                    debugPrint(message);
                  }

                  // Small delay to let GC catch up
                  await Future.delayed(delay);
                }

                debugPrint("✅ Finished large log stress test without crash");
              },

              // onPressed: () {
              //   counter++;
              //   debugPrint("D Info log #$counter");
              //   debugPrint("D Warning log #$counter");
              //   debugPrint("D Error log #$counter");
              //
              //   print("P Info log #$counter");
              //   print("P Warning log #$counter");
              //   print("P Error log #$counter");
              //
              //   setState(() {});
              // },
              child: const Text("Generate Logs"),
            ),
          ],
        ),
      ),
    );
  }
}
