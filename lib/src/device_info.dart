import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'storage.dart';
import 'dart:math';

class SoftLinkDeviceInfo {
  static final _plugin = DeviceInfoPlugin();

  static String? _memoryId;
  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  static String _generateUuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  static Future<String> getDeviceId() async {
    final cached = SoftLinkStorage.getDeviceId();

    if (Platform.isAndroid) {
      // Old SDK versions cached the Build ID here; anything that is not a UUID is replaced.
      if (_memoryId != null) return _memoryId!;
      if (cached != null && _uuidPattern.hasMatch(cached)) {
        _memoryId = cached;
        return cached;
      }
      final id = _generateUuid();
      _memoryId = id;
      await SoftLinkStorage.setDeviceId(id);
      return id;
    }

    if (cached != null && cached.isNotEmpty) return cached;

    String deviceId = '';
    try {
      if (Platform.isIOS) {
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
        fingerprint['device_id'] = await getDeviceId();
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

  static Future<Map<String, dynamic>> getDeviceDetails() async {
    final details = <String, dynamic>{};
    try {
      final view = PlatformDispatcher.instance.views.firstOrNull;
      if (view != null) {
        final pixelRatio = view.devicePixelRatio;
        final screenWidth = (view.physicalSize.width / pixelRatio).round();
        final screenHeight = (view.physicalSize.height / pixelRatio).round();
        details['screen_width'] = screenWidth;
        details['screen_height'] = screenHeight;
      }

      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        details['platform'] = 'android';
        details['os_version'] = info.version.release;
        details['device_model'] = info.model;
        details['device_brand'] = info.brand;
        details['locale'] = Platform.localeName;
        details['user_agent'] =
            'Dalvik/2.1.0 (Linux; U; Android ${info.version.release}; ${info.model} Build/${info.id})';
      } else if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        final machine = info.utsname.machine.toString();
        final isIpad = info.model.toLowerCase().contains('ipad');
        final osUnderscored = info.systemVersion.replaceAll('.', '_');
        details['platform'] = 'ios';
        details['os_version'] = info.systemVersion;
        // Real identifier (e.g. iPhone15,2); falls back to the generic model on simulators
        details['device_model'] =
            (machine.startsWith('iPhone') || machine.startsWith('iPad'))
            ? machine
            : info.model;
        details['locale'] = Platform.localeName;
        details['user_agent'] = isIpad
            ? 'Mozilla/5.0 (iPad; CPU OS $osUnderscored like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
            : 'Mozilla/5.0 (iPhone; CPU iPhone OS $osUnderscored like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
      }
    } catch (_) {}
    return details;
  }
}
