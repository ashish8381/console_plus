# Changelog

## 0.0.1

- Initial release of `console_plus` plugin.
- Added basic logging functionality for Flutter applications.
- Implemented iOS support using CocoaPods (`console_plus.podspec`).
- Included core plugin structure:
    - `Assets/` for resources
    - `Classes/` for platform-specific implementation
    - `Resources/` for bundled iOS assets
- Package validated successfully with 0 warnings.
- **Note:** Swift Package Manager (SPM) support for iOS is not yet included.


## 0.0.2

- Migrated from `dart:js` to `dart:js_interop` (removes deprecation warnings).
- Fixed `console` access error for Flutter Web.
- Improved null-safety and JS interop implementations.
- Cleanup unused example code and improved documentation.
