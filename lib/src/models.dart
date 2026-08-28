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

/// Standard conversion event names for SoftLink tracking.
///
/// Use these constants with [SoftLink.trackConversion] for consistent
/// event naming across all ad platforms.
///
/// ```dart
/// await SoftLink.trackConversion(
///   token: deepLink.token,
///   eventName: SoftLinkEventName.purchase,
///   metadata: SoftLinkConversionMetadata(value: '150', currency: 'SAR'),
/// );
/// ```
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

class SoftLinkConversionMetadata {
  final String? value; // monetary value e.g. "150"
  final String? currency; // ISO 4217 e.g. "SAR", "USD"
  final String? contentId; // product/item ID
  final String? contentName; // product/item name
  final String? contentType; // type e.g. "CarWash", "DoctorSlot"
  final String? quantity; // number of items
  final String? orderId; // order/booking ID
  final Map<String, String>? extra; // any custom fields

  const SoftLinkConversionMetadata({
    this.value,
    this.currency,
    this.contentId,
    this.contentName,
    this.contentType,
    this.quantity,
    this.orderId,
    this.extra,
  });

  Map<String, dynamic> toMap() => {
        if (value != null) 'value': value,
        if (currency != null) 'currency': currency,
        if (contentId != null) 'content_id': contentId,
        if (contentName != null) 'content_name': contentName,
        if (contentType != null) 'content_type': contentType,
        if (quantity != null) 'quantity': quantity,
        if (orderId != null) 'order_id': orderId,
        if (extra != null) ...extra!,
      };
}
