/// Callback type for handling resolved deep links.
///
/// Called with a [SoftLinkDeepLink] when a link is resolved,
/// or `null` if resolution failed or no link was found.
typedef OnSoftLinkDeepLink = void Function(SoftLinkDeepLink? deepLink);

/// Represents a resolved deep link from SoftLink.
class SoftLinkDeepLink {
  /// The unique token identifying this link.
  final String token;

  /// The screen key to navigate to (e.g. `PRODUCT_DETAIL`).
  final String screen;

  /// Parameters associated with this link (e.g. `{'productCode': '207'}`).
  final Map<String, dynamic> params;

  /// The link type: `static` or `dynamic`.
  final String linkType;

  /// Creates a [SoftLinkDeepLink] instance.
  const SoftLinkDeepLink({
    required this.token,
    required this.screen,
    required this.params,
    required this.linkType,
  });

  /// Creates a [SoftLinkDeepLink] from a JSON map.
  factory SoftLinkDeepLink.fromJson(Map<String, dynamic> json) {
    return SoftLinkDeepLink(
      token: json['token'] ?? '',
      screen: json['screen'] ?? '',
      params: Map<String, dynamic>.from(json['params'] ?? {}),
      linkType: json['link_type'] ?? 'static',
    );
  }
}
