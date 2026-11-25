import 'package:get_storage/get_storage.dart';

class SoftLinkStorage {
  static const _box = 'softlink';
  static const _keyLastUri = 'last_handled_uri';
  static const _keyDeviceId = 'device_id';
  static const _keyLinkToken = 'link_token';
  static const _keyLinkTokenSavedAt = 'link_token_saved_at';
  static const _keyLinkTokenHours = 'link_token_hours';

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

  // Link token kept for the per-app duration
  static String? getLinkToken() => _storage.read<String>(_keyLinkToken);
  static int? getLinkTokenSavedAt() => _storage.read<int>(_keyLinkTokenSavedAt);

  static Future<void> setLinkToken(String token, int savedAtMs) async {
    await _storage.write(_keyLinkToken, token);
    await _storage.write(_keyLinkTokenSavedAt, savedAtMs);
  }

  static Future<void> clearLinkToken() async {
    await _storage.remove(_keyLinkToken);
    await _storage.remove(_keyLinkTokenSavedAt);
  }

  /// Per-app duration in hours. null = never fetched, 0 = not set in the portal.
  static int? getLinkTokenHours() => _storage.read<int>(_keyLinkTokenHours);
  static Future<void> setLinkTokenHours(int hours) =>
      _storage.write(_keyLinkTokenHours, hours);
}
