
## ConsolePlus

[![Pub Version](https://img.shields.io/pub/v/console_plus?color=blue)](https://pub.dev/packages/console_plus)
[![Likes](https://img.shields.io/pub/likes/console_plus)](https://pub.dev/packages/console_plus)
[![Pub Points](https://img.shields.io/pub/points/console_plus)](https://pub.dev/packages/console_plus)
[![Flutter Favorite](https://img.shields.io/badge/Flutter-Favorite-cyan)](#)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Flutter%20|%20Android%20|%20iOS%20|%20Web-blue)](#)

<p align="center">
  <img src="https://raw.githubusercontent.com/ashish8381/console_plus/main/logo.png" width="120" alt="Console+ Logo">
</p>

A floating in-app console for Flutter — view, filter, search & export logs while your app runs!  
`console_plus` lets you debug on-device with a floating overlay console that captures print(), debugPrint(), and developer.log() — in real time.

---

## 🆕 Version 2.0.0 & 2.0.1 Highlights

🚀 Major Rewrite for Stability & Zone Safety

- 🧭 Zone-safe initialization — no more “Zone mismatch” errors.  
- 🪄 Unified log capture — `print()` + `debugPrint()` + platform errors all logged automatically.  
- 🧩 Cleaner API — single `ConsolePlus.initApp()` entry point.  
- 🎨 Redesigned console UI — smoother, resizable, searchable overlay.  
- 🧪 Better Flutter Test compatibility — works seamlessly inside test zones.

---

## ✨ Features
✅ Floating draggable console overlay  
✅ Logs display above your app’s UI (non-blocking)  
✅ Captures `print()`, `debugPrint()`, and `developer.log()`  
✅ Auto-scroll when near the bottom  
✅ Filter logs by type (`INFO`, `WARNING`, `ERROR`)  
✅ Keyword search for tags or text  
✅ Copy, clear, and export logs as JSON  
✅ Built-in floating 🐞 debug button  
✅ Captures FlutterError and PlatformDispatcher errors  
✅ Compatible with Flutter 3.16+ / Dart 3+

---

## ⚙️ Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  console_plus: ^2.0.1
```

Then fetch packages:

```bash
flutter pub get
```

Import it:

```bash
import 'package:console_plus/console_plus.dart';
```

---

## 💻 Usage
## Step 1 — Initialize ConsolePlus
Wrap your app inside ConsolePlus.initApp():
```dart
Future<void> main() async {
  await ConsolePlus.initApp(
    const MyApp(),
    interceptPrints: true,          // Capture print() and debugPrint()
    captureFlutterErrors: true,     // Capture Flutter framework errors
    capturePlatformErrors: true,    // Capture platform dispatcher errors
  );
}
```
🧠 This ensures WidgetsFlutterBinding and runApp() are initialized in the same zone — no more zone mismatch errors!

## Step 2 — Show Floating Debug Button

```dart
FloatingDebugButton.show(context);
```
This shows a draggable 🐞 button that opens the console overlay.

---

## Step 2 — Log Messages

Use: 
```dart
DebugLogConsole.log("User logged in successfully");
DebugLogConsole.log("Missing field: email", type: LogType.warning);
DebugLogConsole.log("API request failed", type: LogType.error);
```
Or just use:

```dart
print("Something happened");
debugPrint("App started!");
```
Both are automatically captured by ConsolePlus.

## Step 3 — Export Logs
Tap the ⬇️ Download icon in the console header to export as a .json file.

You can also programmatically call:
```dart
final json = await DebugLogConsole.exportLogs(asJson: true);
```
## 🎛️ Console UI

- 🟢 Floating, draggable, and resizable window
- 🔍 Search bar with keyword filtering
- 🧩 Filter by log levels (Info / Warning / Error)
- 📋 Copy, ⬇️ Export, 🗑️ Clear logs
- 📜 Persistent scroll + multi-line selection
- ⚡ Real-time updates powered by ValueNotifier

## 🧩 Example

```dart
import 'package:flutter/material.dart';
import 'package:console_plus/console_plus.dart';

Future<void> main() async {
  await ConsolePlus.initApp(
    const MyApp(),
    interceptPrints: true,
    captureFlutterErrors: true,
    capturePlatformErrors: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConsolePlus Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int counter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => FloatingDebugButton.show(context),
    );
  }

  void _generateLogs() {
    counter++;
    for (final type in ['Info', 'Warning', 'Error']) {
      debugPrint('D $type log #$counter');
      print('P $type log #$counter');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ConsolePlus Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Button pressed $counter times'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateLogs,
              child: const Text('Generate Logs'),
            ),
          ],
        ),
      ),
    );
  }
}
```
## 📂 File Export

Format: .json

Example output:
```dart
[
  {
    "timestamp": "2025-11-08T12:30:01.345Z",
    "type": "info",
    "message": "App started"
  },
  {
    "timestamp": "2025-11-08T12:31:14.123Z",
    "type": "error",
    "message": "Network timeout"
  }
]
```
---

## 🧭 Upgrading from v1.x → v2.0.1
Before:
```dart
void main() {
  ConsolePlus.init(MyApp());
  runApp(MyApp());
}

```

After (v2.0.0):
```dart
Future<void> main() async {
  await ConsolePlus.initApp(
    const MyApp(),
    interceptPrints: true,
    captureFlutterErrors: true,
    capturePlatformErrors: true,
  );
}
```
✅ ConsolePlus.init() → replaced with ConsolePlus.initApp()
✅ Initialization now must be awaited
✅ Zone-safe by default — fixes zone mismatch crashes
✅ No more manual WidgetsFlutterBinding.ensureInitialized() calls required


## Contributing
PRs welcome. Keep debug-only behaviour intact. If you add native platform code, ensure release builds keep plugin inert unless explicitly enabled.

---

| Floating Button                                                                                                               | Console Overlay                                                                                                        | Search Filter                                                                                                         |
|-------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/ashish8381/console_plus/main/example/screenshots/floatingButton.png" width="250"> | <img src="https://raw.githubusercontent.com/ashish8381/console_plus/main/example/screenshots/console.png" width="250"> | <img src="https://raw.githubusercontent.com/ashish8381/console_plus/main/example/screenshots/filter.png" width="250"> |


---

## 📜 License

[MIT License](https://opensource.org/licenses/MIT) © 2025 [Ashish](https://github.com/ashish8381)  
See the full [LICENSE](https://github.com/ashish8381/console_plus/blob/main/LICENSE) file for details.

---


## 💬 Credits

Built with ❤️ by Ashish
Follow for updates and Flutter dev tips!
