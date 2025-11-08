
# ConsolePlus

<p align="center">
  <img src="https://raw.githubusercontent.com/ashish8381/console_plus/main/logo.png" width="120" alt="Console+ Logo">
</p>

A floating in-app console for Flutter — view, filter, search & export logs while your app runs!
`console_plus` provides a non-intrusive floating console for Flutter apps, designed to debug logs directly on-device.

It helps developers:
- View runtime logs above the app UI
- Debug production issues without connecting to IDE
- Filter and export logs instantly
- Use it in QA or beta builds for field debugging

---

## Features
✅ Floating draggable console overlay  
✅ Logs display **above your app’s UI** (non-blocking)  
✅ Supports **multi-line text selection**  
✅ **Auto-scroll** when near the bottom  
✅ **Filter logs** by type (`INFO`, `WARNING`, `ERROR`)  
✅ **Keyword search** for tags or text  
✅ **Horizontal scrolling** for long lines  
✅ **Copy**, **clear**, and **export** logs as JSON  
✅ Built-in **floating bug icon** to toggle visibility

---

## Installation

Add to your project's `pubspec.yaml`:

```yaml
dependencies:
  console_plus: ^1.0.0
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
## Step 1 — Show Floating Debug Button

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
Or replace all print() calls in your app with:

```dart
DebugLogConsole.customLog("Something happened");
```
## Step 3 — Export Logs
Tap the ⬇️ Download icon in the console header to export as a .json file.
You can also programmatically call:
```dart
final json = await DebugLogConsole.exportLogs(asJson: true);
```
## 🎛️ Console UI

- Draggable & resizable window
- Search bar to filter logs
- Dropdown filter for log levels
- Copy, export, and clear actions
- Persistent scroll and multi-line selection

## 🧩 Example

```dart
void main() {
  runApp(const MyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FloatingDebugButton.show(context);
    DebugLogConsole.log("App started");
  });
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

## Contributing
PRs welcome. Keep debug-only behaviour intact. If you add native platform code, ensure release builds keep plugin inert unless explicitly enabled.

---

| Floating Button                                                                                                          | Console Overlay                                                                                                   | Search Filter                                                                                                    |
|--------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| <img src="https://raw.githubusercontent.com/ashish8381/console_plus/example/screenshots/floatingButton.png" width="250"> | <img src="https://raw.githubusercontent.com/ashish8381/console_plus/example/screenshots/console.png" width="250"> | <img src="https://raw.githubusercontent.com/ashish8381/console_plus/example/screenshots/filter.png" width="250"> |


---

## 📜 License

MIT License © 2025 Ashish
See LICENSE for details.

---

## 💬 Credits

Built with ❤️ by Ashish
Follow for updates and Flutter dev tips!
