import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:console_plus/console_plus.dart';

/// 🧩 Dummy app used for testing
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('TestApp'))),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConsolePlus Tests', () {
    setUp(() {
      DebugLogConsole.clear();
    });

    testWidgets('ConsolePlus.initApp initializes without zone error',
        (tester) async {
      // Should not throw when initializing
      await ConsolePlus.initApp(const TestApp());

      // Just run a frame to verify it built
      await tester.pump(const Duration(milliseconds: 100));
      expect(DebugLogConsole.logs.length, isNonZero);
      expect(
        DebugLogConsole.logs.last.message.contains('ConsolePlus initialized'),
        isTrue,
      );
    });

    test('Captures debugPrint()', () async {
      // Arrange
      DebugLogConsole.clear();
      await ConsolePlus.initApp(const TestApp());

      // Act
      debugPrint('DebugPrint intercepted test');
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      final logs = DebugLogConsole.logs;
      expect(logs.any((l) => l.message.contains('DebugPrint intercepted test')),
          isTrue);
    });

    test('Captures print()', () async {
      // Arrange
      DebugLogConsole.clear();
      await ConsolePlus.initApp(const TestApp());

      // Act
      if (kDebugMode) {
        print('Print interception test');
      }
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      final logs = DebugLogConsole.logs;
      expect(logs.any((l) => l.message.contains('Print interception test')),
          isTrue);
    });

    testWidgets('FloatingConsole UI shows logs dynamically', (tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      FloatingConsole.show(tester.element(find.byType(SizedBox)));

      DebugLogConsole.addLog('Hello Console', type: LogType.info);
      await tester.pump(const Duration(milliseconds: 200));

      expect(FloatingConsole.isVisible, isTrue);
      expect(DebugLogConsole.logs.last.message, contains('Hello Console'));

      FloatingConsole.hide();
      expect(FloatingConsole.isVisible, isFalse);
    });

    testWidgets('FloatingDebugButton toggles FloatingConsole', (tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      FloatingDebugButton.show(tester.element(find.byType(SizedBox)));

      // Simulate tap to open console
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pump(const Duration(milliseconds: 200));
      expect(FloatingConsole.isVisible, isTrue);

      // Tap again to close
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pump(const Duration(milliseconds: 200));
      expect(FloatingConsole.isVisible, isFalse);
    });
  });
}
