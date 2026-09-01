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

import 'dart:io';

import 'package:softlink_flutter/src/device_info.dart';

import 'src/softlink_client.dart';
import 'src/deep_link_handler.dart';
import 'src/storage.dart';
import 'src/models.dart';

/// Standard conversion event names for SoftLink tracking.
/// Use [SoftLinkEventName.custom] for custom event names.
class SoftLinkEventName {
  static const String purchase = 'Purchase';
  static const String booking = 'Booking';
  static const String registration = 'Registration';
  static const String subscription = 'Subscription';
  static const String lead = 'Lead';
  static const String addToCart = 'AddToCart';
  static const String checkout = 'Checkout';
  static const String download = 'Download';
  static const String signUp = 'SignUp';
  static const String login = 'Login';
  static const String search = 'Search';
  static const String viewContent = 'ViewContent';
  static const String custom = 'Custom';
}

/// Main entry point for the SoftLink Flutter SDK.
///
/// Call [SoftLink.init] once at app startup to initialize deep linking.
class SoftLink {
  static SoftLink? _instance;
  late final SoftLinkClient _client;
  late final SoftLinkDeepLinkHandler _handler;

  SoftLink._();

  Future<void> _reportAppOpen() async {
    try {
      final deviceId = await SoftLinkDeviceInfo.getDeviceId();
      final details = await SoftLinkDeviceInfo.getDeviceDetails();
      await _client.reportAppOpen(
        deviceId: deviceId,
        platform: details['platform'] ?? 'android',
        osVersion: details['os_version'],
        deviceModel: details['device_model'],
        screenWidth: details['screen_width'],
        screenHeight: details['screen_height'],
        locale: details['locale'],
      );
    } catch (_) {}
  }

  /// Initializes the SoftLink SDK.
  ///
  /// Must be called before any other SoftLink methods.
  ///
  /// - [baseUrl]: Your SoftLink backend URL. Defaults to `https://api.supersoftlink.com`
  /// - [apiKey]: Your app's API key from the SoftLink portal (starts with `sl_`)
  /// - [onDeepLink]: Callback fired when a deep link is resolved. Receives
  ///   a [SoftLinkDeepLink] with screen and params, or `null` if resolution failed.
  static Future<void> init({
    String baseUrl = 'https://api.supersoftlink.com',
    required String apiKey,
    OnSoftLinkDeepLink? onDeepLink,
    String? idfa,
  }) async {
    _instance = SoftLink._();
    await SoftLinkStorage.init();
    _instance!._client = SoftLinkClient(baseUrl: baseUrl, apiKey: apiKey);
    _instance!._handler = SoftLinkDeepLinkHandler(
      client: _instance!._client,
      onDeepLink: onDeepLink,
      idfa: idfa,
    );
    await _instance!._handler.init();
    // Get GAID on Android for ad platform signal quality
    if (Platform.isAndroid) {
      SoftLinkClient.getGAID().then((gaid) {
        if (gaid != null) {
          SoftLinkDeviceInfo.getDeviceId().then((deviceId) {
            _instance!._client.setUserData(
              deviceId: deviceId,
              maid: gaid,
            );
          });
        }
      }).catchError((_) {});
    }
    // Report app open for ad platform tracking
    _instance!._reportAppOpen();
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

  /// Tracks a conversion event for a deep link.
  ///
  /// - [token]: The deep link token received in [onDeepLink] callback
  /// - [eventName]: Name of the conversion event (e.g. `Purchase`, `Booking`)
  /// - [metadata]: Optional map of additional data (e.g. `{'amount': '150', 'currency': 'SAR'}`)
  ///
  /// Returns `true` if the conversion was tracked successfully.
  ///
  /// ```dart
  /// await SoftLink.trackConversion(
  ///   token: deepLink.token,
  ///   eventName: 'Purchase',
  ///   metadata: {'packageId': '1122', 'amount': '150'},
  /// );
  /// ```
  static Future<bool> trackConversion({
    required String token,
    required String eventName,
    SoftLinkConversionMetadata? metadata,
  }) async {
    assert(_instance != null,
        'SoftLink not initialized. Call SoftLink.init() first.');
    return _instance!._client.trackConversion(
      token: token,
      eventName: eventName,
      metadata: metadata,
    );
  }

  /// Triggers a custom event defined in the SoftLink portal.
  ///
  /// - [eventKey]: The event key (UPPERCASE_WITH_UNDERSCORES) defined in portal
  /// - [linkToken]: Optional deep link token to associate this event with a link
  /// - [sequence]: Optional sequence number defined by the developer
  /// - [lastEventKey]: Optional previous event key fired before this one
  /// - [metadata]: Optional event metadata matching the schema defined in portal
  ///
  /// Returns `true` if the event was triggered successfully.
  ///
  /// ```dart
  /// await SoftLink.triggerEvent(
  ///   eventKey: 'PRODUCT_PURCHASE',
  ///   linkToken: deepLink.token,
  ///   sequence: 1,
  ///   lastEventKey: 'PRODUCT_DETAIL',
  ///   metadata: {'productId': '123', 'purchaseDate': '2026-08-28'},
  /// );
  /// ```
  static Future<bool> triggerEvent({
    required String eventKey,
    String? linkToken,
    int? sequence,
    String? lastEventKey,
    Map<String, dynamic>? metadata,
  }) async {
    assert(_instance != null,
        'SoftLink not initialized. Call SoftLink.init() first.');
    return _instance!._client.triggerEvent(
      eventKey: eventKey,
      linkToken: linkToken,
      sequence: sequence,
      lastEventKey: lastEventKey,
      metadata: metadata,
    );
  }

  /// Sets user data for improved ad platform signal quality.
  ///
  /// Call this after user logs in. Email and phone are SHA256 hashed
  /// before sending — never sent in plain text.
  ///
  /// ```dart
  /// await SoftLink.setUserData(
  ///   email: 'user@example.com',
  ///   phone: '+1234567890',
  /// );
  /// ```
  static Future<bool> setUserData({
    String? email,
    String? phone,
    String? maid,
  }) async {
    assert(_instance != null,
        'SoftLink not initialized. Call SoftLink.init() first.');
    final deviceId = await SoftLinkDeviceInfo.getDeviceId();
    return _instance!._client.setUserData(
      email: email,
      phone: phone,
      maid: maid,
      deviceId: deviceId,
    );
  }
}
