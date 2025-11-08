import 'package:flutter_test/flutter_test.dart';
import 'package:console_plus/console_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('should add and clear logs', () {
    DebugLogConsole.addLog("Hello", type: LogType.info);
    expect(DebugLogConsole.logs.length, 1);

    DebugLogConsole.clear();
    expect(DebugLogConsole.logs.isEmpty, true);
  });

  test('should export logs as JSON', () async {
    DebugLogConsole.addLog("Test", type: LogType.error);
    final json = await DebugLogConsole.exportLogs(asJson: true);
    expect(json.contains("Test"), true);
  });
}
