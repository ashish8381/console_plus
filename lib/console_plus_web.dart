// lib/console_plus_web.dart

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'console_plus.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop'; // ✅ Required for .toJS

class ConsolePlusWeb {
  static void registerWith(Registrar registrar) {
    DebugLogConsole.customLog = _logToWeb;
  }

  /// ✅ Log to web console + Flutter UI storage
  static void _logToWeb(String message, {LogType type = LogType.info}) {
    // Save inside ConsolePlus UI
    DebugLogConsole.addLog(message, type: type);

    final formatted =
        "[${DateTime.now().toIso8601String()}] (${type.name.toUpperCase()}) $message";

    // ✅ Convert Dart String → JSAny using .toJS
    switch (type) {
      case LogType.error:
        web.console.error(formatted.toJS);
        break;
      case LogType.warning:
        web.console.warn(formatted.toJS);
        break;
      default:
        web.console.log(formatted.toJS);
        break;
    }
  }
}
