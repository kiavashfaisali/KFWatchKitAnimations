#
# Be sure to run `pod lib lint KFWatchKitAnimations.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'KFWatchKitAnimations'
  s.version          = '2.0.0'
  s.summary          = 'KFWatchKitAnimations creates beautiful 60 FPS animations on  Watch by recording animations from the iOS Simulator.'
  s.homepage         = 'https://github.com/kiavashfaisali/KFWatchKitAnimations'

  s.license          = { :type => 'MIT',
               :file => 'LICENSE' }
  s.authors          = { 'Kiavash Faisali' => 'kiavashfaisali@outlook.com' }
  s.source           = { :git => 'https://github.com/kiavashfaisali/KFWatchKitAnimations.git',
               :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'KFWatchKitAnimations/Classes/**/*'
end
