Pod::Spec.new do |s|
  s.name             = 'softlink_flutter'
  s.version          = '0.0.7'
  s.summary          = 'SoftLink Flutter SDK for deep linking and install attribution.'
  s.description      = 'SoftLink Flutter SDK for deep linking, deferred deep linking, and install attribution with Play Install Referrer and SKAdNetwork support.'
  s.homepage         = 'https://github.com/Supersoft-Corporation/SL-SDK-Flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Supersoft Corporation' => 'dev@supersoft.com.pk' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
  s.frameworks       = 'StoreKit'
end