# Changelog

All notable changes to this project will be documented here.

---

## 0.0.1
- 🎉 Initial release of `console_plus` plugin.
- Added basic logging functionality for Flutter applications.
- Implemented iOS support using CocoaPods (`console_plus.podspec`).
- Included core plugin structure:
  - `Assets/` for resources
  - `Classes/` for platform-specific implementations
  - `Resources/` for bundled iOS assets
- Package validated successfully with **0 warnings**.
- ⚠️ Note: Swift Package Manager (SPM) support for iOS not yet included.

---

## 0.0.2
- 🧩 Migrated from `dart:js` to `dart:js_interop` to remove deprecation warnings.
- 🕸️ Fixed console access errors on **Flutter Web** builds.
- ✅ Improved null-safety and JS interop consistency.
- 🧹 Cleaned up unused example code and enhanced documentation.

---

## 1.0.0
- 🚀 **Major update:** Introduced **floating in-app console overlay**.
- Added draggable and resizable floating console window.
- Introduced `FloatingDebugButton` 🐞 to toggle visibility dynamically.
- Added log filtering by `LogType` (`INFO`, `WARNING`, `ERROR`).
- Added keyword-based search for tag or message filtering.
- Implemented multi-line **text selection** and **copy** support.
- Integrated **auto-scroll** detection (scrolls only if user is at bottom).
- Added **horizontal scrolling** for long log lines.
- Enhanced UI with rounded corners, translucent black background, and adaptive layout.
- Added **download/export feature** (saves logs as `.json` via `file_saver` package).
- Improved time formatting — displays `[HH:mm:ss.SSS]` instead of full ISO date.
- Fixed issue where console covered full screen; now opens at 50% height with resize support.
- ⚡ Optimized large log handling (up to 2,000 entries retained).
- Prevented text selection from resetting when new logs arrive.
- Improved filter & search performance with `ValueListenableBuilder`.
- Added persistence to scroll behavior when updating logs.
- Minor UI polish — compact layout on small screens and better padding on controls.
- 🧾 Added **SnackBar confirmation** after exporting logs.
- Added graceful error handling for failed export attempts.
- Refined drag-and-resize logic for smoother UX.
- Improved accessibility contrast and dark theme consistency.
- Internal refactor for better log notifier updates (removed manual listeners).
- 🪄 Refined `SelectableText` behavior for stable multi-line selection.
- Fixed bug where selection was lost on log updates.
- Added horizontal + vertical scroll sync for long logs.
- Enhanced file export naming: uses timestamp-based file names (`debug_logs_YYYY-MM-DD_HH-mm-ss.json`).
- Documentation and logo added for GitHub and pub.dev release.

## 1.0.1

## 📦 Maintenance & Improvements
- ✅ Updated all dependencies to the latest stable versions:
  - file_saver → ^0.3.1
  - path_provider → ^2.1.5
  - plugin_platform_interface → ^2.1.8
- ⚙️ Improved compatibility with Flutter 3.24+ SDK
- 🧹 Minor internal cleanup and formatting (dart format .)
- 🧠 Ready for Dart 3.x and Flutter 3.10+ environments

## 🧑‍💻 Developer Note:
  This update improves your plugin’s pub.dev score by ensuring dependency freshness and Flutter compatibility.

## 1.1.1

## 📦 Release Mode Improvements

- 🧹 Hide Debug Floating Button in Release Mode


## 2.0.0
🚀 **Major Rewrite & Stability Upgrade**

This release introduces a complete overhaul of **ConsolePlus**, focused on stability, compatibility, and full log interception across Flutter environments.

---

### ✨ **New Features**
- ✅ **Unified print interception**
  - `print()` and `debugPrint()` are now both captured automatically using a single Zone-based system.
  - All intercepted logs appear instantly in the in-app console.
- ✅ **Zone-safe Flutter initialization**
  - Fixed all *“Zone mismatch”* errors by initializing `WidgetsFlutterBinding` and `runApp()` within the same zone.
  - Ensures compatibility with Flutter 3.24+ and Dart 3 zones.
- ✅ **Automatic Flutter & Platform error capture**
  - All uncaught `FlutterError`s and platform-level errors are logged in the console with full stack traces.
- ✅ **Improved floating console UI**
  - Draggable, resizable overlay with better readability.
  - Real-time log filtering (**Info / Warning / Error**).
  - Search bar with live results.
  - One-click **copy**, **export (JSON)**, and **clear logs** actions.
- ✅ **New floating debug button**
  - Quick toggle to show/hide the floating console from anywhere in the app.
  - Automatically attaches to the root overlay safely after the first frame.
- ✅ **Persistent scroll & auto-scroll**
  - Console remembers user scroll position and only auto-scrolls when near the bottom.
- ✅ **Export logs**
  - Export logs as plain text or JSON file.
  - Integrated with `file_saver` for desktop and mobile exports.

---

### 🧩 **Under the Hood**
- Rewritten `ConsolePlus.initApp()` for clean Zone management.
- Added `_detectType()` logic to classify logs as `info`, `warning`, or `error`.
- Simplified `DebugLogConsole` architecture for speed and thread safety.
- Added `PrintCapturer` for early print interception before app startup.
- Added `ConsolePlusLog.overrideLogHandler()` for custom `developer.log` interception.
- Improved UI rendering performance and eliminated rebuild flicker.

### ⚠️ **Breaking Changes**
- `ConsolePlus.init()` renamed to **`ConsolePlus.initApp()`**.
- Initialization now must be awaited:
  ```dart
  await ConsolePlus.initApp(
    const MyApp(),
    interceptPrints: true,
    captureFlutterErrors: true,
    capturePlatformErrors: true,
  );
