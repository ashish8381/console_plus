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
