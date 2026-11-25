import 'softlink_client.dart';
import 'storage.dart';

/// Values sent as `trigger_type` with every event.
class SoftLinkTriggerType {
  static const String appToken = 'inorganic'; // the app passed the token
  static const String storedToken =
      'indirect-inorganic'; // SDK added the stored token
  static const String noToken = 'organic'; // no token from the app or the SDK
}

/// Keeps the last link token for the duration set for this app in the SoftLink portal.
class SoftLinkLinkToken {
  static Future<void>? _pendingConfig;

  /// Starts fetching the per-app duration. Never throws.
  static void refreshConfig(SoftLinkClient client) {
    _pendingConfig = _fetch(client);
  }

  static Future<void> _fetch(SoftLinkClient client) async {
    try {
      final config = await client.fetchConfig();
      if (config == null) return; // request failed: keep what is cached
      final raw = config['link_token_retention_hours'];
      final hours = raw is num ? raw.toInt() : 0;
      await SoftLinkStorage.setLinkTokenHours(hours);
      if (hours <= 0) await SoftLinkStorage.clearLinkToken();
    } catch (_) {}
  }

  /// Waits for the setting only when it has never been fetched on this device.
  static Future<int> _hours() async {
    var hours = SoftLinkStorage.getLinkTokenHours();
    if (hours == null && _pendingConfig != null) {
      try {
        await _pendingConfig!.timeout(const Duration(seconds: 3));
      } catch (_) {}
      hours = SoftLinkStorage.getLinkTokenHours();
    }
    return hours ?? 0;
  }

  /// Saves [token] and restarts the timer. Does nothing when no duration is set.
  static Future<void> save(String? token) async {
    try {
      final value = token?.trim();
      if (value == null || value.isEmpty) return;
      if (await _hours() <= 0) return;
      await SoftLinkStorage.setLinkToken(
        value,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  /// The saved token while it is inside the duration, otherwise null (and cleared).
  static Future<String?> active() async {
    try {
      final hours = await _hours();
      final token = SoftLinkStorage.getLinkToken();
      if (token == null || token.isEmpty) return null;
      final savedAt = SoftLinkStorage.getLinkTokenSavedAt();
      final age = savedAt == null
          ? null
          : DateTime.now().difference(
              DateTime.fromMillisecondsSinceEpoch(savedAt),
            );
      final valid =
          hours > 0 &&
          age != null &&
          !age.isNegative &&
          age < Duration(hours: hours);
      if (!valid) {
        await SoftLinkStorage.clearLinkToken();
        return null;
      }
      return token;
    } catch (_) {
      return null;
    }
  }
}
