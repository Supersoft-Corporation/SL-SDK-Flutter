class SoftLinkDeepLink {
  final String token;
  final String screen;
  final Map<String, dynamic> params;
  final String linkType;

  const SoftLinkDeepLink({
    required this.token,
    required this.screen,
    required this.params,
    required this.linkType,
  });

  factory SoftLinkDeepLink.fromJson(Map<String, dynamic> json) {
    return SoftLinkDeepLink(
      token: json['token'] ?? '',
      screen: json['screen'] ?? '',
      params: Map<String, dynamic>.from(json['params'] ?? {}),
      linkType: json['link_type'] ?? 'static',
    );
  }
}

typedef OnSoftLinkDeepLink = void Function(SoftLinkDeepLink? deepLink);
