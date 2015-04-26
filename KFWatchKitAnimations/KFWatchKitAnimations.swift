/*
    KFWatchKitAnimations is available under the MIT license.

    Copyright (c) 2015 Kiavash Faisali
    https://github.com/kiavashfaisali

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

//
//  KFWatchKitAnimations.swift
//  KFWatchKitAnimations
//
//  Created by Kiavash Faisali on 2015-02-17.
//  Copyright (c) 2015 Kiavash Faisali. All rights reserved.
//

import UIKit

private var durationAssociationKey: UInt8 = 0
private var imageDocumentsPathAssociationKey: UInt8 = 0
private var imageNameAssociationKey: UInt8 = 0
private var snapshotNumberAssociationKey: UInt8 = 0
private var completionHolderAssociationKey: UInt8 = 0

extension UIView {
    final private class CompletionHolder {
        let completion: ((finished: Bool) -> Void)?
        
        init(completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    final private var duration: CFTimeInterval! {
        get {
            return objc_getAssociatedObject(self, &durationAssociationKey) as? CFTimeInterval
        }
        set {
            objc_setAssociatedObject(self, &durationAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    final private var imageDocumentsPath: String! {
        get {
            return objc_getAssociatedObject(self, &imageDocumentsPathAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &imageDocumentsPathAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    final private var imageName: String! {
        get {
            return objc_getAssociatedObject(self, &imageNameAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &imageNameAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    final private var snapshotNumber: Int! {
        get {
            return objc_getAssociatedObject(self, &snapshotNumberAssociationKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &snapshotNumberAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    final private var completionHolder: CompletionHolder! {
        get {
            return objc_getAssociatedObject(self, &completionHolderAssociationKey) as? CompletionHolder
        }
        set {
            objc_setAssociatedObject(self, &completionHolderAssociationKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    /**
    Records the view and it's entire hierarchy at 60 FPS and stores the resulting image collection in a sub-folder within the the app's Documents folder. The file path will be outputted in the console at runtime.
    
    :param: duration The duration (in seconds) of the animation.
    :param: imageName The name of the image collection (as well as the sub-folder in Documents). Do not add a "-" at the end as that will already be appended. For example, if imageName is "Example", then the collection will be Example-0@2x.png, Example-1@2x.png, etc.
    :param: animations An optional closure containing the animations to sync with. Alternatively, you can call this function with nil animations and it will record all activity on the view which performed the call for the specified duration. The default value is nil.
    :param: completion An optional closure which acts as an entry point for chaining recordings in order to split up a long, complex animation into several sub-animations. A Bool parameter contains the state of whether or not the recording was successful. The default value is nil.
    */
    final public func snapshotsWithDuration(duration: CFTimeInterval, imageName: String, animations: (() -> Void)? = nil, completion: ((finished: Bool) -> Void)? = nil) {
        if duration <= 0 {
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let documentsDirectory = documentsPath[0] as? String {
            let imageDirectory = documentsDirectory.stringByAppendingPathComponent(imageName)
            
            var error: NSError?
            fileManager.removeItemAtPath(imageDirectory, error: nil)
            if fileManager.createDirectoryAtPath(imageDirectory, withIntermediateDirectories: true, attributes: nil, error: &error) {
                self.imageDocumentsPath = imageDirectory
            }
            else {
                println("\n[KFWatchKitAnimations] Failed to create directory with name \(imageName): \(error!.localizedDescription)\n")
                completion?(finished: false)
                return
            }
        }
        
        self.imageName = imageName
        self.snapshotNumber = 0
        self.duration = CACurrentMediaTime() + duration
        self.completionHolder = CompletionHolder(completion: completion)
        let displayLink = CADisplayLink(target: self, selector: "takeSnapshot:")
        animations?()
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    final internal func takeSnapshot(displayLink: CADisplayLink) {
        if displayLink.timestamp > self.duration {
            displayLink.invalidate()
            println("\n[KFWatchKitAnimations] Finished writing '\(self.imageName)' to the filesystem.\n")
            println("\n[KFWatchKitAnimations] \(self.imageDocumentsPath)\n")
            self.completionHolder.completion?(finished: true)
        }
        else if self.snapshotNumber > 1024 {
            displayLink.invalidate()
            println("\n[KFWatchKitAnimations] This animation has exceeded the maximum number of images WatchKit will allow. As a work-around, please record the sub-animations individually.\n")
            self.completionHolder.completion?(finished: false)
        }
        else {
            let imagePath = self.imageDocumentsPath.stringByAppendingPathComponent("\(self.imageName)-\(self.snapshotNumber)@2x.png")
            UIImagePNGRepresentation(self.snapshot()).writeToFile(imagePath, atomically: true)
            ++self.snapshotNumber!
        }
    }
    
    final private func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return snapshotImage
    }
}