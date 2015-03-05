# KFWatchKitAnimations

This project provides an extremely easy-to-use tool for Apple Watch developers with which they can create gorgeous, smooth 60 FPS animations in a way that is highly optimized for WatchKit by recording arbitrary animations from an iPhone or iPad Simulator.

## The Problem
Currently, a developer seeking to create animations for Apple Watch will require the aid of a talented designer that can break down an animation into individual "snapshots" of the animation in progress, which when stitched together form the illusion of a continuous, high frame-rate animation.

## The Solution
``` Swift
extension UIView {
    func snapshotsWithDuration(duration: CFTimeInterval, imageName: String, animations: (() -> Void)?, completion: ((finished: Bool) -> Void)?
}
```

That's right, one function in one file - KFWatchKitAnimations.swift - without the need of any import statements or boilerplate code, will generate beautiful 60 FPS animations as a series of consecutive images that will be packaged in a folder on your filesystem that you can then drag-and-drop into your Apple Watch app for immediate use.

It just works.

## KFWatchKitAnimations Requirements
* Xcode 6.1 or higher
* iOS 7.0 or higher

## WatchKitAnimations Sample App Requirements
* Xcode 6.2 or higher
* iOS 8.2 or higher

### CocoaPods
To ensure you stay up-to-date with the latest version of KFWatchKitAnimations, it is recommended that you use CocoaPods.

Add the following to your Podfile
``` bash
platform :ios, '7.0'
pod 'KFWatchKitAnimations'
```

## Example Usage
``` swift
self.someView.snapshotsWithDuration(1.0, imageName: "fadeOutThenInView", animations: {
    UIView.animateWithDuration(0.5, animations: {
        self.someView.alpha = 0.0
    }) { finished in
        UIView.animateWithDuration(0.5) {
            self.someView.alpha = 1.0
        }
    }
}, completion: nil)
```

Since the "animations" block in the above function is optional, you can instead implement the above example like this:
``` swift
UIView.animateWithDuration(0.5, animations: {
    self.someView.alpha = 0.0
}) { finished in
    UIView.animateWithDuration(0.5) {
        self.someView.alpha = 1.0
    }
}

self.someView.snapshotsWithDuration(1.0, imageName: "fadeOutThenInView", animations: nil, completion: nil)
```

While the latter solution enables you to capture snapshots of animations you may have in existing apps with very little modification to the original code, it's important to know that the former less initial internal setup overhead with greatly increased legibility, thus it is greatly preferred.

## Sample App
Please download the sample app "WatchKitAnimations" in this repository for a clear idea of how to create complex animations for Apple Watch.

## Contact Information
Kiavash Faisali
- https://github.com/kiavashfaisali
- kiavashfaisali@outlook.com
