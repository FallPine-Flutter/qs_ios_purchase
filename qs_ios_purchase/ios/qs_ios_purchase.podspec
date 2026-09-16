#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint qs_ios_purchase.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'qs_ios_purchase'
  s.version          = '1.0.7'
  s.summary          = 'A Flutter plugin for iOS StoreKit 2 purchases.'
  s.description      = <<-DESC
A Flutter plugin for iOS StoreKit 2 purchases, subscriptions, restore flows,
transaction checks, and purchase-related event streams.
                       DESC
  s.homepage         = 'https://github.com/fallpine/qs_ios_purchase'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'fallpine' => 'fallpine@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'QSInAppPurchase', '1.3.0'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'qs_ios_purchase_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
