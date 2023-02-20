import 'package:flutter/services.dart';

class Volumedeck {
  static const _methodChannel =
      MethodChannel('@com.navideck.volumedeck_flutter');
  static const _messageConnector = BasicMessageChannel(
      "@com.navideck.volumedeck_flutter/message_connector",
      StandardMessageCodec());
  static bool _isInitialize = false;

  /// call [initialize] once with required parameters
  static Future<void> initialize({
    bool runInBackground = false,
    bool showStopButtonInAndroidNotification = false,
    bool showSpeedAndVolumeChangesInAndroidNotification = false,
    bool useAndroidWakeLock = false,
    bool autoHandleAndroidPermissions = true,
    bool requiresAndroidBackgroundPermission = false,
    String? activationKey,
  }) async {
    if (_isInitialize) throw "Volumedeck already initialized";
    await _methodChannel.invokeMethod("initialize", {
      "runInBackground": runInBackground,
      "activationKey": activationKey,
      "showStopButtonInNotification": showStopButtonInAndroidNotification,
      "showSpeedAndVolumeChangesInNotification":
          showSpeedAndVolumeChangesInAndroidNotification,
      "useWakeLock": useAndroidWakeLock,
      "autoHandleAndroidPermissions": autoHandleAndroidPermissions,
      "requiresAndroidBackgroundPermission":
          requiresAndroidBackgroundPermission,
    });
    _isInitialize = true;
  }

  static void setUpdateListener({
    VoidCallback? onStart,
    VoidCallback? onStop,
    Function(bool status)? onLocationStatusChange,
    Function(double speed, double volume)? onLocationUpdate,
  }) {
    _messageConnector.setMessageHandler((dynamic message) async {
      var type = message["type"];
      var data = message["data"];
      switch (type) {
        case "onStart":
          onStart?.call();
          break;
        case "onStop":
          onStop?.call();
          break;
        case "onLocationStatusChange":
          onLocationStatusChange?.call(data);
          break;
        case "onLocationUpdate":
          onLocationUpdate?.call(data["speed"], data["volume"]);
          break;
      }
      return null;
    });
  }

  static void removeUpdateListener() =>
      _messageConnector.setMessageHandler(null);

  static Future start() async {
    if (!_isInitialize) throw "Volumedeck not initialized";
    _methodChannel.invokeMethod('start');
  }

  static Future stop() {
    if (!_isInitialize) throw "Volumedeck not initialized";
    return _methodChannel.invokeMethod('stop');
  }
}
