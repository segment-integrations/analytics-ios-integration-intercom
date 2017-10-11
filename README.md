# Segment-Intercom

[![CI Status](http://img.shields.io/travis/segment-integrations/analytics-ios-integration-intercom.svg?style=flat)](https://travis-ci.org/segment-integrations/analytics-ios-integration-intercom)
[![Version](https://img.shields.io/cocoapods/v/Segment-Intercom.svg?style=flat)](http://cocoapods.org/pods/Segment-Intercom)
[![License](https://img.shields.io/cocoapods/l/Segment-Intercom.svg?style=flat)](http://cocoapods.org/pods/Segment-Intercom)
[![Platform](https://img.shields.io/cocoapods/p/Segment-Intercom.svg?style=flat)](http://cocoapods.org/pods/Segment-Intercom)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

Segment-Intercom is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Segment-Intercom'
```

After adding the dependency, you must import the integration: `'SEGIntercomIntegrationFactory.h'`. And finally, register it with the Segment SDK: `[configuration use:[SEGIntercomIntegrationFactory instance]];`.

When installing Intercom, you'll need to make sure that you have a `NSPhotoLibraryUsageDescription` entry in your `Info.plist`.
 
 This is [required by Apple](https://developer.apple.com/library/content/qa/qa1937/_index.html) for all apps that access the photo library. It is necessary when installing Intercom due to the image upload functionality. Users will be prompted for the photo library permission only when they tap the image upload button.

## License

Segment-Intercom is available under the MIT license. See the LICENSE file for more info.
