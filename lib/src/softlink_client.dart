import 'dart:convert';
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
}
