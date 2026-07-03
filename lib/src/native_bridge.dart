import 'dart:io';
import 'package:flutter/services.dart';

/// Handles native platform communication for SoftLink SDK.
class SoftLinkNativeBridge {
  static const _channel = MethodChannel('softlink_flutter');

  /// Gets the Play Install Referrer string (Android only).
  /// Returns null on iOS or if referrer is not available.
  static Future<String?> getInstallReferrer() async {
    if (!Platform.isAndroid) return null;
    try {
      return await _channel.invokeMethod<String>('getInstallReferrer');
    } catch (e) {
      return null;
    }
  }

  /// Registers app for SKAdNetwork attribution (iOS only).
  /// Returns true if successful, false otherwise.
  static Future<bool> registerSKAdNetwork() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>('registerSKAdNetwork') ?? false;
    } catch (e) {
      return false;
    }
  }
}
