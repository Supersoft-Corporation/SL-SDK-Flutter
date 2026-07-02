import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'device_info.dart';

class SoftLinkClient {
  final String baseUrl;
  final String apiKey;

  SoftLinkClient({required this.baseUrl, required this.apiKey});

  Future<SoftLinkDeepLink?> resolveToken(String token) async {
    try {
      final fingerprint = await SoftLinkDeviceInfo.getDeviceFingerprint();
      final uri = Uri.parse('$baseUrl/api/links/token/$token').replace(
        queryParameters: fingerprint,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) return SoftLinkDeepLink.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<SoftLinkDeepLink?> resolveDeferred() async {
    try {
      final fingerprint = await SoftLinkDeviceInfo.getDeviceFingerprint();
      final uri = Uri.parse('$baseUrl/api/links/resolve').replace(
        queryParameters: fingerprint,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) return SoftLinkDeepLink.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> updateFingerprintDeviceId(String deviceId) async {
    try {
      await http
          .post(
            Uri.parse('$baseUrl/api/links/fingerprint/update'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'device_id': deviceId}),
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      }
    } catch (e) {
      debugPrint('SoftLink: generateReferralLink error: $e');
    }
    return null;
  }
}
