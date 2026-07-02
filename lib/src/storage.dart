import 'package:get_storage/get_storage.dart';

class SoftLinkStorage {
  static const _box = 'softlink';
  static const _keyLastUri = 'last_handled_uri';
  static const _keyDeviceId = 'device_id';

  static final _storage = GetStorage(_box);

  static Future<void> init() async {
    await GetStorage.init(_box);
  }

  static String? getLastUri() => _storage.read(_keyLastUri);
  static Future<void> setLastUri(String uri) =>
      _storage.write(_keyLastUri, uri);
  static Future<void> clearLastUri() => _storage.remove(_keyLastUri);

  static String? getDeviceId() => _storage.read(_keyDeviceId);
  static Future<void> setDeviceId(String id) =>
      _storage.write(_keyDeviceId, id);
}
