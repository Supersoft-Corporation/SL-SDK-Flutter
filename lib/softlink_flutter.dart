export 'src/models.dart';

import 'package:softlink_flutter/softlink_flutter.dart';

import 'src/softlink_client.dart';
import 'src/deep_link_handler.dart';
import 'src/storage.dart';

class SoftLink {
  static SoftLink? _instance;
  late final SoftLinkClient _client;
  late final SoftLinkDeepLinkHandler _handler;

  SoftLink._();

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

  static SoftLink get instance {
    assert(_instance != null,
        'SoftLink not initialized. Call SoftLink.init() first.');
    return _instance!;
  }
}
