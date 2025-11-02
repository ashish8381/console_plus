import 'package:flutter/services.dart';

import 'console_plus_platform_interface.dart';

class MethodChannelConsolePlus extends ConsolePlusPlatform {
  final methodChannel = const MethodChannel('console_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
