# KFWatchKitAnimations

This project aims to provide an extremely easy-to-use tool for  Watch developers with which they can create gorgeous, smooth 60 FPS animations in a way that is highly optimized for WatchKit by recording arbitrary animations from an iPhone/iPad Simulator.

## The Problem
Currently, a developer seeking to create animations for  Watch will require the aid of a talented designer that can break down an animation into individual snapshot images of the animation in progress, which when stitched together form the illusion of a continuous, high frame-rate animation.

This is in stark contrast to what iOS developers are accustomed to since frameworks like CoreAnimation and CoreGraphics are not at their disposal when developing for  Watch.

## The Solution
``` Swift
extension UIView {
    func snapshotsWithDuration(duration: CFTimeInterval, imageName: String, animations: (() -> Void)?, completion: ((finished: Bool) -> Void)?
}
```

That's right, one function in one file - KFWatchKitAnimations.swift - without the need of any import statements or boilerplate code, will generate beautiful 60 FPS animations as a series of consecutive images. These images are located inside a sub-folder within the iOS Simulator's Documents folder that you can then drag-and-drop into your  Watch app for immediate use.

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

Make sure to check the console as you're recording your animations as the file path to the folder containing your recorded animations will be printed there.
After copying the file path that was printed in the console, simply open Finder and press "Cmd + Shift + G" followed by pasting the copied file path.
Lastly, drag-and-drop the animation folder into your WatchKit app and you're done!

Note: A single recording that's been optimized for the 42mm  Watch will scale really well on the 38mm size, so don't worry about doubling up on the recording.

## Sample App
Please download the sample app "WatchKitAnimations" in this repository for a clear idea of how to create complex animations for  Watch.

## Contact Information
Kiavash Faisali
- https://github.com/kiavashfaisali
- kiavashfaisali@outlook.com

## License
KFWatchKitAnimations is available under the MIT license.

Copyright (c) 2015 Kiavash Faisali

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
