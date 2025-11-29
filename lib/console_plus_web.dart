import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'console_plus.dart';

class ConsolePlusWeb {
  static void registerWith(Registrar registrar) {
    DebugLogConsole.customLog = _logToWeb;
  }

  static void _logToWeb(String message, {LogType type = LogType.info}) {
    DebugLogConsole.addLog(message, type: type);
  }
}
