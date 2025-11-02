import 'package:console_plus/console_plus.dart';
import 'package:console_plus/console_plus_method_channel.dart';
import 'package:console_plus/console_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockConsolePlusPlatform
    with MockPlatformInterfaceMixin
    implements ConsolePlusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ConsolePlusPlatform initialPlatform = ConsolePlusPlatform.instance;

  test('$MethodChannelConsolePlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelConsolePlus>());
  });

  test('getPlatformVersion', () async {
    ConsolePlus consolePlusPlugin = ConsolePlus();
    MockConsolePlusPlatform fakePlatform = MockConsolePlusPlatform();
    ConsolePlusPlatform.instance = fakePlatform;

    expect(await consolePlusPlugin.getPlatformVersion(), '42');
  });
}
