/// SoftLink Flutter SDK for deep linking and install attribution.
///
/// Initialize with [SoftLink.init] at app startup:
/// ```dart
/// SoftLink.init(
///   baseUrl: 'https://your-backend.com',
///   apiKey: 'sl_your_key',
///   onDeepLink: (deepLink) {
///     if (deepLink == null) return;
///     navigateTo(deepLink.screen, deepLink.params);
///   },
/// );
/// ```
library softlink_flutter;

export 'src/models.dart';

import 'src/softlink_client.dart';
import 'src/deep_link_handler.dart';
import 'src/storage.dart';
import 'src/models.dart';

/// Main entry point for the SoftLink Flutter SDK.
///
/// Call [SoftLink.init] once at app startup to initialize deep linking.
class SoftLink {
  static SoftLink? _instance;
  late final SoftLinkClient _client;
  late final SoftLinkDeepLinkHandler _handler;

  SoftLink._();

  /// Initializes the SoftLink SDK.
  ///
  /// Must be called before any other SoftLink methods.
  ///
  /// - [baseUrl]: Your SoftLink backend URL (e.g. `https://api-link.yourapp.com`)
  /// - [apiKey]: Your app's API key from the SoftLink portal (starts with `sl_`)
  /// - [onDeepLink]: Callback fired when a deep link is resolved. Receives
  ///   a [SoftLinkDeepLink] with screen and params, or `null` if resolution failed.
  static Future<void> init({
    required String baseUrl,
    required String apiKey,
    OnSoftLinkDeepLink? onDeepLink,
  }) async {
    _instance = SoftLink._();
    await SoftLinkStorage.init();
    _instance!._client = SoftLinkClient(baseUrl: baseUrl, apiKey: apiKey);
    _instance!._handler = SoftLinkDeepLinkHandler(
      client: _instance!._client,
      onDeepLink: onDeepLink,
    );
    await _instance!._handler.init();
  }

  /// Returns the current [SoftLink] instance.
  ///
  /// Throws an assertion error if [SoftLink.init] has not been called.
  static SoftLink get instance {
    assert(_instance != null,
        'SoftLink not initialized. Call SoftLink.init() first.');
    return _instance!;
  }

  /// Generates a shareable referral/deep link at runtime.
  ///
  /// - [screenKey]: The screen key (e.g. `PRODUCT_DETAIL`)
  /// - [values]: Runtime parameters (e.g. `{'productCode': '207'}`)
  /// - [referrerId]: Optional referrer ID stored as `ref` param
  /// - [token]: Optional parent dynamic link token. If omitted, the first
  ///   dynamic link matching [screenKey] is used.
  ///
  /// Returns the generated URL, or `null` if generation failed.
  ///
  /// Same values always return the same URL (deduplication).
  ///
  /// ```dart
  /// final url = await SoftLink.generateReferralLink(
  ///   screenKey: 'PRODUCT_DETAIL',
  ///   values: {'productCode': '207'},
  ///   token: 'abc12345',
  /// );
  /// if (url != null) Share.share(url);
  /// ```
  static Future<String?> generateReferralLink({
    required String screenKey,
    required Map<String, String> values,
    String? referrerId,
    String? token,
  }) async {
    assert(_instance != null,
        'SoftLink not initialized. Call SoftLink.init() first.');
    return _instance!._client.generateReferralLink(
      screenKey: screenKey,
      values: values,
      referrerId: referrerId,
      token: token,
    );
  }
}
