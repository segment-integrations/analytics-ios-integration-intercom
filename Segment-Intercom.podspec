#
# Be sure to run `pod lib lint Segment-Intercom.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Segment-Intercom'
  s.version          = '1.0.1'
  s.summary          = 'Intercom Integration for Segment\'s analytics-ios library.'

  s.description      = <<-DESC
  Analytics for iOS provides a single API that lets you
  integrate with over 100s of tools.
  This is the Optimizely X integration for the iOS library.
                       DESC

  s.homepage         = 'http://segment.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Segment' => 'friends@segment.com' }
  s.source           = { :git => 'https://github.com/segment-integrations/analytics-ios-integration-intercom.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/segment'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Segment-Intercom/Classes/**/*'
  s.dependency 'Analytics'
  s.dependency 'Intercom'
end
