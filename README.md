# CocoaPods Acknowledgements

A CocoaPods plugin that generates a plist which includes the installation metadata. This currently provides it in a format made to work with [CPDAcknowledgements](https://github.com/cocoapods/CPDAcknowledgements) ( A CocoaPod for showing your acknowledgements in-app.) It is expected to also take ownership of generating `Setting.bundle` compatible plists too, in order to remove that functionality from CocoaPods core.

To use this once installed via `gem install cocoapods-acknowledgements` you need to be using at least CocoaPods `0.36` and add `plugin 'cocoapods-acknowledgements'` to your `Podfile`. 
