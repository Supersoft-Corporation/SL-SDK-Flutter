import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
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

  Future<SoftLinkDeepLink?> resolveToken(
    String token, {
    String? utmSource,
  }) async {
    try {
      final fingerprint = await SoftLinkDeviceInfo.getDeviceFingerprint();
      final queryParams = {
        ...fingerprint,
        if (utmSource != null && utmSource.isNotEmpty) 'utm_source': utmSource,
      };
      final uri = Uri.parse(
        '$baseUrl/api/links/token/$token',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) return SoftLinkDeepLink.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<SoftLinkDeepLink?> resolveDeferred({
    String? referrer,
    String? deviceId,
  }) async {
    try {
      final fingerprint = await SoftLinkDeviceInfo.getDeviceFingerprint();
      final queryParams = {
        ...fingerprint,
        if (referrer != null) 'referrer': referrer,
        if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      };
      final uri = Uri.parse(
        '$baseUrl/api/links/resolve',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) return SoftLinkDeepLink.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateFingerprintDeviceId(
    String deviceId, {
    String? referrer,
    String? maid,
  }) async {
    try {
      final details = await SoftLinkDeviceInfo.getDeviceDetails();
      await http
          .post(
            Uri.parse('$baseUrl/api/links/fingerprint/update'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'device_id': deviceId,
              if (referrer != null) 'referrer': referrer,
              if (maid != null) 'maid': maid,
              ...{
                for (final k in _deviceDetailKeys)
                  if (details[k] != null) k: details[k],
              },
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
        'values': {...values, if (referrerId != null) 'ref': referrerId},
      };

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
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

  Future<bool> setUserData({
    String? email,
    String? phone,
    String? maid,
    Map<String, dynamic>? userData,
    required String deviceId,
  }) async {
    try {
      String? hashedEmail;
      String? hashedPhone;

      if (email != null && email.isNotEmpty) {
        hashedEmail = _sha256(email.toLowerCase().trim());
      }
      if (phone != null && phone.isNotEmpty) {
        // Ad platforms expect digits only, with country code (no '+', spaces or dashes)
        var normalized = phone.replaceAll(RegExp(r'\D'), '');
        if (normalized.startsWith('00')) normalized = normalized.substring(2);
        if (normalized.isNotEmpty) hashedPhone = _sha256(normalized);
      }

      final extra = _buildUserData(userData);

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/links/user-data'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'device_id': deviceId,
              if (hashedEmail != null) 'hashed_email': hashedEmail,
              if (hashedPhone != null) 'hashed_phone': hashedPhone,
              if (maid != null) 'maid': maid,
              if (extra.isNotEmpty) 'user_data': extra,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('SoftLink: setUserData error: $e');
      return false;
    }
  }

  Future<bool> reportAppOpen({
    required String deviceId,
    required String platform,
    String? osVersion,
    String? deviceModel,
    String? deviceBrand,
    String? userAgent,
    int? screenWidth,
    int? screenHeight,
    String? locale,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/links/app-open'),
            headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
            body: jsonEncode({
              'device_id': deviceId,
              'platform': platform,
              if (osVersion != null) 'os_version': osVersion,
              if (deviceModel != null) 'device_model': deviceModel,
              if (deviceBrand != null) 'device_brand': deviceBrand,
              if (userAgent != null) 'user_agent': userAgent,
              if (screenWidth != null) 'screen_width': screenWidth,
              if (screenHeight != null) 'screen_height': screenHeight,
              if (locale != null) 'locale': locale,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('SoftLink: reportAppOpen error: $e');
      return false;
    }
  }

  String _sha256(String input) {
    // SHA256 using dart:convert
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static const _deviceDetailKeys = [
    'platform',
    'os_version',
    'device_model',
    'device_brand',
    'screen_width',
    'screen_height',
    'locale',
    'user_agent',
  ];

  // Keys the SDK hashes (SHA-256, trimmed + lowercased) before sending.
  // Matching ignores case and underscores: first_name, firstName and FIRSTNAME all work.
  static const _hashedUserDataKeys = {
    'firstname': 'firstName',
    'lastname': 'lastName',
    'city': 'city',
    'state': 'state',
    'zip': 'zip',
    'country': 'country',
    'gender': 'gender',
    'dob': 'dob',
  };

  Map<String, dynamic> _buildUserData(Map<String, dynamic>? input) {
    final out = <String, dynamic>{};
    if (input == null) return out;
    input.forEach((key, value) {
      if (value == null) return;
      final canonical =
          _hashedUserDataKeys[key.toLowerCase().replaceAll('_', '')];
      if (canonical != null) {
        final text = value.toString().trim().toLowerCase();
        if (text.isNotEmpty) out[canonical] = _sha256(text);
      } else {
        if (value is String && value.trim().isEmpty) return;
        out[key] = value;
      }
    });
    return out;
  }

  /// Per-app SDK settings from the SoftLink portal. Returns null if the request fails.
  Future<Map<String, dynamic>?> fetchConfig() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/sdk/config'),
            headers: {'X-API-Key': apiKey},
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) return data;
      }
    } catch (e) {
      debugPrint('SoftLink: fetchConfig error: $e');
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
            headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
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
    required String triggerType,
    String? linkToken,
    int? sequence,
    String? lastEventKey,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/events/trigger'),
            headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
            body: jsonEncode({
              'event_key': eventKey,
              'trigger_type': triggerType,
              if (linkToken != null) 'link_token': linkToken,
              if (sequence != null) 'sequence': sequence,
              if (lastEventKey != null) 'last_event_key': lastEventKey,
              if (metadata != null) 'metadata': metadata,
              'platform': Platform.isIOS ? 'ios' : 'android',
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('SoftLink: triggerEvent error: $e');
      return false;
    }
  }

  static Future<String?> getGAID() async {
    try {
      return cleanMaid(await _channel.invokeMethod<String>('getGAID'));
    } catch (e) {
      return null;
    }
  }

  /// Returns [id], or null when it is empty or all zeros (ad ID unavailable or opted out).
  static String? cleanMaid(String? id) {
    if (id == null) return null;
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;
    if (RegExp(r'^[0\-]+$').hasMatch(trimmed)) return null;
    return trimmed;
  }
}
