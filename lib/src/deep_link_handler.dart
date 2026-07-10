import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:softlink_flutter/src/device_info.dart';
import 'package:softlink_flutter/src/models.dart';
import 'package:softlink_flutter/src/native_bridge.dart';
import 'softlink_client.dart';
import 'storage.dart';

class SoftLinkDeepLinkHandler {
  final SoftLinkClient _client;
  final OnSoftLinkDeepLink? onDeepLink;
  final _appLinks = AppLinks();
  String? _processingToken;
  DateTime? _lastHandledTime;
  String? _lastHandledToken;
  bool _initialUriHandled = false;
  StreamSubscription? _subscription;

  SoftLinkDeepLinkHandler({
    required SoftLinkClient client,
    this.onDeepLink,
  }) : _client = client;

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();

    await _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('SoftLink: stream fired: $uri');
      if (!_initialUriHandled &&
          initialUri != null &&
          uri.toString() == initialUri.toString()) {
        debugPrint('SoftLink: stream ignored (same as initial)');
        return;
      }
      SoftLinkStorage.setLastUri(uri.pathSegments.last);
      _handleUri(uri);
    });

    if (initialUri != null) {
      final token = initialUri.pathSegments.isNotEmpty
          ? initialUri.pathSegments.last
          : '';
      final lastUri = SoftLinkStorage.getLastUri();

      // Skip stale or already-handled URIs
      if (lastUri != null && lastUri != token) {
        _initialUriHandled = true;
        await _checkDeferred();
        return;
      }
      if (lastUri == token) {
        _initialUriHandled = true;
        await _checkDeferred();
        return;
      }

      await SoftLinkStorage.setLastUri(token);
      _initialUriHandled = true;
      await _handleUri(initialUri);
      return;
    }

    await _checkDeferred();
  }

  Future<void> _handleUri(Uri uri) async {
    debugPrint('SoftLink: _handleUri called: $uri');
    if (uri.pathSegments.isEmpty) return;
    final token = uri.pathSegments.last;
    if (token.isEmpty) return;

    // Deduplicate — ignore same token within 2 seconds
    final now = DateTime.now();
    if (_lastHandledToken == token &&
        _lastHandledTime != null &&
        now.difference(_lastHandledTime!).inMilliseconds < 2000) {
      debugPrint('SoftLink: duplicate URI ignored: $token');
      return;
    }
    _lastHandledToken = token;
    _lastHandledTime = now;

    if (_processingToken == token) return;
    _processingToken = token;

    // Extract utm_source from URI
    final utmSource = uri.queryParameters['utm_source'] ?? '';

    try {
      final deepLink = await _client.resolveToken(token, utmSource: utmSource);
      if (deepLink != null) {
        onDeepLink?.call(deepLink);
      } else {
        onDeepLink?.call(null);
      }
    } catch (e) {
      onDeepLink?.call(null);
    } finally {
      _processingToken = null;
    }
  }

  Future<void> _checkDeferred() async {
    // Register SKAdNetwork on iOS
    await SoftLinkNativeBridge.registerSKAdNetwork();

    // Get Play Install Referrer on Android
    final referrer = await SoftLinkNativeBridge.getInstallReferrer();
    final deviceId = await SoftLinkDeviceInfo.getDeviceId();
    if (deviceId.isNotEmpty) {
      await _client.updateFingerprintDeviceId(deviceId, referrer: referrer);
    }
    final deepLink = await _client.resolveDeferred(referrer: referrer);
    if (deepLink != null) onDeepLink?.call(deepLink);
  }
}
