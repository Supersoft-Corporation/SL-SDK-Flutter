# softlink_flutter

Official Flutter SDK for [SoftLink](https://supersoftlink.com) — a deep link management platform.

## Features

- 🔗 Deep linking (when app is already installed)
- 📦 Deferred deep linking (when app is not installed)
- 📱 Device-level install attribution (Android ID / iOS IDFV)
- 🎯 Snapchat CAPI integration support
- 🔄 Automatic duplicate URI handling
- 💾 Persistent storage via GetStorage

## Installation

```yaml
dependencies:
  softlink_flutter: ^0.0.12
```

## Usage

Initialize the SDK in your `main.dart`:

```dart
import 'package:softlink_flutter/softlink_flutter.dart';

void main() {
  runApp(MyApp());
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SoftLink.init(
      baseUrl: 'https://your-softlink-backend.com',
      apiKey: 'sl_your_api_key',
      onDeepLink: (deepLink) {
        if (deepLink == null) return;
        print('Screen: ${deepLink.screen}');
        print('Params: ${deepLink.params}');
      },
    );
  }
}
```

## Generating Referral Links (Dynamic Links)

Use `SoftLink.generateReferralLink()` to generate shareable deep links at runtime:

```dart
// Without token (finds first dynamic link matching screenKey):
final url = await SoftLink.generateReferralLink(
  screenKey: 'PRODUCT_DETAIL',
  values: {'productId': '209', 'categoryId': '220'},
  referrerId: currentUser.id, // optional
);

// With token (targets a specific dynamic link):
final url = await SoftLink.generateReferralLink(
  screenKey: 'PRODUCT_DETAIL',
  values: {'productId': '209', 'categoryId': '220'},
  token: 'PARENT_TOKEN', // from SoftLink portal
  referrerId: currentUser.id,
);

if (url != null) {
  Share.share(url); // share via any app
}
```


### Trigger Events

Trigger custom events defined in the SoftLink portal to track user actions tied to deep links.

### Step 1 — Create an event in SoftLink portal

Go to your app → Events → Create event with a key (e.g. `PURCHASE`) and define metadata fields.

### Step 2 — Save the token when deep link resolves

```dart
String? _deepLinkToken;

SoftLink.init(
  baseUrl: 'https://api.supersoftlink.com',
  apiKey: 'sl_your_api_key',
  onDeepLink: (deepLink) {
    if (deepLink == null) return;
    _deepLinkToken = deepLink.token; // save token
    navigateTo(deepLink.screen, deepLink.params);
  },
);
```

### Step 3 — Trigger event when user completes action

```dart
await SoftLink.triggerEvent(
  eventKey: 'PURCHASE',          // must match key defined in portal
  linkToken: _deepLinkToken,     // associates event with the deep link
  sequence: 1,                   // optional: order of event in user journey
  lastEventKey: 'VIEW_ITEM',     // optional: previous event key
  metadata: {
    'item_id': 'item-001',
    'amount': '99.00',
    'currency': 'USD',
  },
);

// Clear token after event
_deepLinkToken = null;
```

### Step 4 — Clear token when screen is disposed

```dart
@override
void dispose() {
  _deepLinkToken = null; // clear if user leaves without completing action
  super.dispose();
}
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eventKey` | `String` | ✅ Yes | Event key defined in SoftLink portal (UPPERCASE_WITH_UNDERSCORES) |
| `linkToken` | `String?` | No | Deep link token to associate event with a link. If not passed, event is tracked as organic |
| `sequence` | `int?` | No | Order of this event in the user journey, defined by developer |
| `lastEventKey` | `String?` | No | Previous event key fired before this one |
| `metadata` | `Map<String, dynamic>?` | No | Key-value pairs matching the metadata schema defined in portal |

### Notes
- Event key must exist in SoftLink portal and be set to **Active** status ✅
- If `linkToken` is not passed, event is counted as **organic** (no link attribution) ✅
- Metadata fields should match the schema defined in the portal ✅
- Events are visible in SoftLink portal under app → Events → Analytics ✅


## Set User Data (Signal Quality)

Call `SoftLink.setUserData()` after user logs in to improve ad platform signal quality. Email and phone are SHA256 hashed before sending — never sent in plain text.

**Note:** GAID (Android) is collected automatically by the SDK on init. IDFA (iOS) is passed via `SoftLink.init(idfa: idfa)` after ATT permission. You do not need to pass MAID manually.

```dart
// Call after user logs in
await SoftLink.setUserData(
  email: 'user@example.com',   // will be SHA256 hashed
  phone: '+1234567890',         // will be SHA256 hashed
);
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email` | `String?` | No | User email — automatically lowercased, trimmed and SHA256 hashed |
| `phone` | `String?` | No | User phone number — spaces and dashes removed, then SHA256 hashed |
| `maid` | `String?` | No | Optional — only needed if you manage MAID manually. GAID (Android) and IDFA (iOS via ATT) are handled automatically by the SDK |

### Notes
- Call this once after user logs in ✅
- GAID on Android is automatically collected on `SoftLink.init()` ✅
- IDFA on iOS is passed via `SoftLink.init(idfa: idfa)` after ATT permission ✅
- Data is used to improve Snapchat, Meta and TikTok CAPI signal quality ✅
- Never pass pre-hashed values — SDK handles hashing automatically ✅

---

## App Open Tracking

The SDK automatically calls `reportAppOpen()` on every `SoftLink.init()` — no additional code needed.

This fires an `APP_OPEN` event to connected ad platforms (Snapchat, Meta, TikTok) with real device info including OS version, device model and locale for improved signal quality.

```dart
// This is called automatically on init — no extra code needed
await SoftLink.init(
  baseUrl: 'https://your-softlink-backend.com',
  apiKey: 'sl_your_api_key',
  onDeepLink: (deepLink) { ... },
);
// APP_OPEN event fires automatically ✅
```

### What is sent
- Device platform (Android/iOS)
- OS version
- Device model
- Locale
- Device ID
- Hashed email/phone (if previously set via `setUserData()`)
- MAID/IDFA (if available)

---

## Android Setup

Add to `android/app/src/main/AndroidManifest.xml` inside `<activity>`:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" android:host="your-domain.com" android:pathPrefix="/l/"/>
</intent-filter>
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="yourscheme" android:host="l"/>
</intent-filter>
```

Add to `MainActivity.kt`:

```kotlin
override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
}
```

## iOS Setup

Add to `Runner.entitlements`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:your-domain.com</string>
</array>
```

Add to `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>yourscheme</string>
    </array>
  </dict>
</array>
```

Add to `AppDelegate.swift`:

```swift
// Handle Universal Links when app is already running
override func application(
  _ application: UIApplication,
  continue userActivity: NSUserActivity,
  restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
  return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
}

// Handle custom scheme URLs when app is already running
override func application(
  _ app: UIApplication,
  open url: URL,
  options: [UIApplication.OpenURLOptionsKey: Any] = [:]
) -> Bool {
  return super.application(app, open: url, options: options)
}
```

## iOS Deferred Deep Linking (IDFA)

By default, SoftLink uses IDFV (Identifier for Vendor) for iOS deferred deep linking. For improved accuracy, you can pass the IDFA (Identifier for Advertisers) when the user grants App Tracking Transparency (ATT) permission.

### Why IDFA improves accuracy

- **IDFV** — available without permission but resets when all vendor apps are uninstalled
- **IDFA** — persistent unique device identifier, works even when IP changes (CGNAT), much more reliable for install attribution

### Implementation

**Step 1 — Add ATT package to your app:**

```yaml
dependencies:
  app_tracking_transparency: ^2.0.6
```

**Step 2 — Add to `ios/Runner/Info.plist`:**

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use this identifier to improve your app experience and provide relevant content.</string>
```

**Step 3 — Request ATT and pass IDFA to SDK:**

```dart
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:softlink_flutter/softlink_flutter.dart';

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    String? idfa;

    if (Platform.isIOS) {
      try {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await Future.delayed(const Duration(milliseconds: 500));
          final result = await AppTrackingTransparency.requestTrackingAuthorization();
          if (result == TrackingStatus.authorized) {
            idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
            if (idfa == '00000000-0000-0000-0000-000000000000') idfa = null;
          }
        } else if (status == TrackingStatus.authorized) {
          idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
          if (idfa == '00000000-0000-0000-0000-000000000000') idfa = null;
        }
      } catch (_) {}
    }

    await SoftLink.init(
      baseUrl: 'https://your-softlink-backend.com',
      apiKey: 'sl_your_api_key',
      idfa: idfa, // pass IDFA when available
      onDeepLink: (deepLink) {
        if (deepLink == null) return;
        // handle navigation
      },
    );
  });
}
```

**Notes:**
- ATT permission is optional — SDK falls back to IDFV if IDFA is unavailable ✅
- Show ATT prompt at the right time — avoid conflicts with notification permission dialogs ✅
- Apple requires `NSUserTrackingUsageDescription` in `Info.plist` — App Store will reject without it ✅
- IDFA is only available on iOS — Android uses Android ID automatically ✅

## License

Apache
