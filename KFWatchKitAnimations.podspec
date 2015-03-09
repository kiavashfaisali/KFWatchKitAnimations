Pod::Spec.new do |s|
  s.name        = 'KFWatchKitAnimations'
  s.version     = '1.0'
  s.summary     = 'KFWatchKitAnimations creates beautiful 60 FPS animations on  Watch by recording animations from the iOS Simulator.'
  s.homepage    = 'https://github.com/kiavashfaisali/KFWatchKitAnimations'
  s.license     = { :type => 'MIT',
		    :file => 'LICENSE' }
  s.authors     = { 'kiavashfaisali' => 'kiavashfaisali@outlook.com' }

  s.platform = :ios, '8.0'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.source   = { :git => 'https://github.com/kiavashfaisali/KFWatchKitAnimations.git',
		 :tag => s.version.to_s }
  s.source_files = 'KFWatchKitAnimations/*.swift'
end
