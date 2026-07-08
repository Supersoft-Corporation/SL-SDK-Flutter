# Changelog

## 0.0.9

* Pass utm_source from URI to resolveToken for accurate traffic source tracking via Universal Links

## 0.0.8

* Fixed deep link re-triggering after first use by removing `_initialUriHandled` flag from stream check
* Added HTTP 201 status code support alongside 200 for runtime link generation response
* Fixed Android manifest: removed deprecated `package` attribute, added `queries` block for Play Install Referrer API support on Android 11+

## 0.0.7

* Updated the configuration to handle the `initial_uri` utilized twice
* Added the `Google Referrer API` and the `SKAdNetwork` Support

## 0.0.6

* Updated `device_info_plus` constraint to `^13.2.0`
* Added the Platform Support
* Added the fallback URL, and made the URL field optional

## 0.0.5

* Updated `device_info_plus` constraint to `^11.5.0`
* Updated `app_links` constraint to `^7.2.0`
* Fixed example `pubspec.yaml` SDK constraint
* Added `generateReferralLink` method for runtime dynamic link generation
* Added dartdoc comments to all public API elements
* Added example app
* Updated repository URL to `https://github.com/Supersoft-Corporation/SL-SDK-Flutter`

## 0.0.4

* Updated the README.md file to the correct version
* No code changes from 0.0.1

## 0.0.3

* Published under verified publisher supersoft.com.pk
* No code changes from 0.0.1

## 0.0.2

* Published under verified publisher supersoft.com.pk
* No code changes from 0.0.1

## 0.0.1

* Initial public release
* Deep linking support (app already installed)
* Deferred deep linking via IP + device fingerprinting
* Device-level install attribution (Android ID / iOS IDFV)
* Automatic duplicate URI deduplication
* GetStorage-based persistent storage
* Snapchat CAPI integration support via SoftLink backend
* `onDeepLink` callback for custom navigation handling
* Support for static and dynamic link types