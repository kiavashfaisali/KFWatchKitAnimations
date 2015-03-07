Pod::Spec.new do |s|
  s.name        = 'KFWatchKitAnimations'
  s.version     = '1.0'
  s.summary     = 'KFWatchKitAnimations enables beautiful 60 FPS animations on Apple Watch by recording arbitrary animations from an iOS app as an ordered collection of images.'
  s.homepage    = 'https://github.com/kiavashfaisali/KFWatchKitAnimations'
  s.license     = { :type => 'MIT',
		    :file => 'LICENSE' }
  s.authors     = { 'kiavashfaisali' => 'kiavashfaisali@outlook.com' }

  s.platform = :ios, '7.0'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.source   = { :git => 'https://github.com/kiavashfaisali/KFWatchKitAnimations.git',
		 :tag => s.version.to_s }
  s.source_files = 'KFWatchKitAnimations'
end
