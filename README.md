
# ConsolePlus

**ConsolePlus** is a Flutter debug helper plugin that shows an in-app debug console accessible via a floating button.  
It is intended **for debug builds only** and will not show or run in release builds when used as directed.

---

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Quick Start (example)](#quick-start-example)
- [API](#api)
- [Best practices (Debug-only)](#best-practices-debug-only)
- [Advanced usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Features
- Floating draggable debug button (configurable by app)
- In-app log viewer with filter (info, warning, error)
- Auto-scroll to latest log
- Export logs as text or JSON (library helper)
- Safe: no UI or logging in release builds if used as documented

---

## Installation

Add to your project's `pubspec.yaml`:

```yaml
dependencies:
  console_plus:
    path: ../console_plus   # or use published version: ^x.y.z
```

Then fetch packages:

```bash
flutter pub get
```

---

## Quick Start (example)

Example `main.dart` that starts a periodic timer and shows the floating button to open ConsolePlus:

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:console_plus/console_plus.dart';

Timer? _timer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  // start timer after UI is built so Overlay exists
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (kDebugMode) startTimer();
  });
}

void startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 2), (_) {
    final now = DateTime.now();
    // prints to IDE console
    print("⏱ Timer Log: $now");
    // logs to ConsolePlus internal list (debug-only)
    DebugLogConsole.log("⏱ Timer Log: $now");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ConsolePlus Demo')),
        body: const Center(child: Text('Tap the bug to view logs')),
        floatingActionButton: kDebugMode
            ? Builder(
                builder: (context) => FloatingActionButton(
                  child: const Icon(Icons.bug_report),
                  onPressed: () => DebugLogConsole.show(context),
                ),
              )
            : null,
      ),
    );
  }
}
```

---

## API

### `DebugLogConsole.log(String message, {LogType type = LogType.info})`
Add a log entry (only active in debug builds).

```dart
DebugLogConsole.log("User tapped button", type: LogType.info);
DebugLogConsole.log("Value is null", type: LogType.warning);
DebugLogConsole.log("Unhandled exception", type: LogType.error);
```

### `DebugLogConsole.show(BuildContext context)`
Show the floating console overlay (must be called with a context inside a `MaterialApp` / `Scaffold`).

### `DebugLogConsole.hide()`
Hide the overlay if shown.

### `DebugLogConsole.exportLogs({bool asJson = false})`
Returns the logs as a `String` in text or JSON format.

---

## Best practices (Debug-only)

- The plugin contains `kDebugMode` guards internally, but **still** prefer adding `kDebugMode` around any UI that calls `DebugLogConsole.show(context)` in your app:

```dart
floatingActionButton: kDebugMode
  ? FloatingActionButton(... show console ...)
  : null,
```

- Start timers or background log sources **after** the app first frame (`WidgetsBinding.instance.addPostFrameCallback`) to ensure `Overlay` exists.

- Do **not** call `DebugLogConsole.show()` from `main()` before `runApp()`.

---

## Advanced usage

### Listening for logs in your app
If you need to react to new logs in your own UI, ConsolePlus exposes a `ValueNotifier`:

```dart
DebugLogConsole.logsNotifier.addListener(() {
  final logs = DebugLogConsole.logsNotifier.value;
  // update your UI or send logs to a server (only in debug)
});
```

### Exporting logs
```dart
final text = await DebugLogConsole.exportLogs();
final json = await DebugLogConsole.exportLogs(asJson: true);
```

On mobile you can save to a file using `path_provider` and share with `share_plus`. On web you can download as a file using a Blob.

---

## Troubleshooting

### "No Overlay widget found"
- Ensure you call `DebugLogConsole.show(context)` with a context that belongs to a widget under `MaterialApp` and `Scaffold`.
- Use `Builder` to get a proper inner context:
```dart
floatingActionButton: Builder(builder: (ctx) => FloatingActionButton(onPressed: () => DebugLogConsole.show(ctx)))
```

### UI doesn't update when logs are added
- Use `DebugLogConsole.logsNotifier` to listen for updates; UI must rebuild on notifier change.

### Timer stops or UI freezes when console is open
- Don't create timers inside the console widget. Keep timers global or in app-level state and only call `DebugLogConsole.log()` from the timer callback.
- Avoid heavy `setState()` calls every time a log arrives; use `ValueListenableBuilder` or incremental updates.

---

## Contributing
PRs welcome. Keep debug-only behaviour intact. If you add native platform code, ensure release builds keep plugin inert unless explicitly enabled.

---

## License
MIT © Ashish
# console_plus
