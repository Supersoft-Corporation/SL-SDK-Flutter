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
  softlink_flutter: ^0.1.0
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

## SoftLinkDeepLink

| Property | Type | Description |
|----------|------|-------------|
| `token` | `String` | Unique link token |
| `screen` | `String` | Screen key (e.g. `DOCTOR_PROFILE`) |
| `params` | `Map<String, dynamic>` | Link parameters |
| `linkType` | `String` | `static` or `dynamic` |

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

## License

Apache
