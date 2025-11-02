import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'console_plus_method_channel.dart';

abstract class ConsolePlusPlatform extends PlatformInterface {
  /// Constructs a ConsolePlusPlatform.
  ConsolePlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConsolePlusPlatform _instance = MethodChannelConsolePlus();

  /// The default instance of [ConsolePlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelConsolePlus].
  static ConsolePlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ConsolePlusPlatform] when
  /// they register themselves.
  static set instance(ConsolePlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

