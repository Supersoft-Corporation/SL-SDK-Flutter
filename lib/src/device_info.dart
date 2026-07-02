import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'storage.dart';

class SoftLinkDeviceInfo {
  static final _plugin = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    // Return cached device ID if available
    final cached = SoftLinkStorage.getDeviceId();
    if (cached != null && cached.isNotEmpty) return cached;

    String deviceId = '';

    try {
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        // Use Android ID as device identifier
        deviceId = info.id;
      } else if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        // Use IDFV (no permission needed)
        deviceId = info.identifierForVendor ?? '';
      }
    } catch (e) {
      deviceId = '';
    }

    if (deviceId.isNotEmpty) {
      await SoftLinkStorage.setDeviceId(deviceId);
    }

    return deviceId;
  }

  static Future<Map<String, String>> getDeviceFingerprint() async {
    final fingerprint = <String, String>{};

    try {
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        fingerprint['platform'] = 'android';
        fingerprint['model'] = info.model;
        fingerprint['brand'] = info.brand;
        fingerprint['os_version'] = info.version.release;
        fingerprint['device_id'] = info.id;
      } else if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        fingerprint['platform'] = 'ios';
        fingerprint['model'] = info.model;
        fingerprint['os_version'] = info.systemVersion;
        fingerprint['device_id'] = info.identifierForVendor ?? '';
      }
    } catch (_) {}

    return fingerprint;
  }
}
