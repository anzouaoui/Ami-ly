import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Met à jour le badge de l'icône de l'application (iOS + Android).
///
/// iOS : `UIApplication.shared.applicationIconBadgeNumber`.
/// Android : intents multi-launchers (Samsung, Huawei, OPPO, Xiaomi, Sony…).
class BadgeService {
  static const _channel = MethodChannel('com.app.amily/badge');

  static Future<void> setCount(int count) async {
    try {
      await _channel.invokeMethod('setBadgeCount', {'count': count});
    } on PlatformException catch (e) {
      debugPrint('[BadgeService] Error: $e');
    }
  }

  static Future<void> clear() => setCount(0);
}
