import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'device_info.dart';
import 'package:flutter/services.dart';

class SoftLinkClient {
  final String baseUrl;
  final String apiKey;

  SoftLinkClient({required this.baseUrl, required this.apiKey});

  static const _channel = MethodChannel('softlink_flutter');

  static Future<String?> getInstallReferrer() async {
    try {
      return await _channel.invokeMethod<String>('getInstallReferrer');
    } catch (e) {
      return null;
    }
  }

  static Future<bool> registerSKAdNetwork() async {
    try {
      return await _channel.invokeMethod<bool>('registerSKAdNetwork') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<SoftLinkDeepLink?> resolveToken(String token,
      {String? utmSource}) async {
    try {
      final fingerprint = await SoftLinkDeviceInfo.getDeviceFingerprint();
      final queryParams = {
        ...fingerprint,
        if (utmSource != null && utmSource.isNotEmpty) 'utm_source': utmSource,
      };
      final uri = Uri.parse('$baseUrl/api/links/token/$token').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) return SoftLinkDeepLink.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<SoftLinkDeepLink?> resolveDeferred(
      {String? referrer, String? deviceId}) async {
    try {
      final fingerprint = await SoftLinkDeviceInfo.getDeviceFingerprint();
      final queryParams = {
        ...fingerprint,
        if (referrer != null) 'referrer': referrer,
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      };
      final uri = Uri.parse('$baseUrl/api/links/resolve').replace(
        queryParameters: queryParams,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) return SoftLinkDeepLink.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateFingerprintDeviceId(String deviceId,
      {String? referrer}) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/api/links/fingerprint/update'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'device_id': deviceId,
              if (referrer != null) 'referrer': referrer,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  Future<String?> generateReferralLink({
    required String screenKey,
    required Map<String, String> values,
    String? referrerId,
    String? token,
  }) async {
    try {
      final uri = token != null
          ? Uri.parse('$baseUrl/api/runtime/link?token=$token')
          : Uri.parse('$baseUrl/api/runtime/link');

      final body = {
        'screen': screenKey,
        'values': {
          ...values,
          if (referrerId != null) 'ref': referrerId,
        },
      };

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      }
    } catch (e) {
      debugPrint('SoftLink: generateReferralLink error: $e');
    }
    return null;
  }

  Future<bool> trackConversion({
    required String token,
    required String eventName,
    SoftLinkConversionMetadata? metadata,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/links/$token/conversion'),
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': apiKey,
            },
            body: jsonEncode({
              'event_name': eventName,
              if (metadata != null) 'metadata': metadata.toMap(),
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('SoftLink: trackConversion error: $e');
      return false;
    }
  }

  Future<bool> triggerEvent({
    required String eventKey,
    String? linkToken,
    int? sequence,
    String? lastEventKey,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/events/trigger'),
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': apiKey,
            },
            body: jsonEncode({
              'event_key': eventKey,
              if (linkToken != null) 'link_token': linkToken,
              if (sequence != null) 'sequence': sequence,
              if (lastEventKey != null) 'last_event_key': lastEventKey,
              if (metadata != null) 'metadata': metadata,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('SoftLink: triggerEvent error: $e');
      return false;
    }
  }
}
