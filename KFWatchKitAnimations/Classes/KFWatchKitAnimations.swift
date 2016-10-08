//
//  Created by Kiavash Faisali on 2015-02-17.
//  Copyright (c) 2016 Kiavash Faisali. All rights reserved.
//

import UIKit

private var durationAssociationKey: UInt8 = 0
private var imageDocumentsURLAssociationKey: UInt8 = 0
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
            objc_setAssociatedObject(self, &durationAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final private var imageDocumentsURL: NSURL! {
        get {
            return objc_getAssociatedObject(self, &imageDocumentsURLAssociationKey) as? NSURL
        }
        set {
            objc_setAssociatedObject(self, &imageDocumentsURLAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final private var imageName: String! {
        get {
            return objc_getAssociatedObject(self, &imageNameAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &imageNameAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final private var snapshotNumber: Int! {
        get {
            return objc_getAssociatedObject(self, &snapshotNumberAssociationKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &snapshotNumberAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final private var completionHolder: CompletionHolder! {
        get {
            return objc_getAssociatedObject(self, &completionHolderAssociationKey) as? CompletionHolder
        }
        set {
            objc_setAssociatedObject(self, &completionHolderAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
    Records the view and it's entire hierarchy at 60 FPS and stores the resulting image collection in a sub-folder within the the app's Documents folder. The file path will be printed in the console at runtime.
    
    - parameter duration: The duration (in seconds) of the animation.
    - parameter imageName: The name of the image collection (as well as the sub-folder in Documents). Do not add a "-" at the end as that will already be appended. For example, if imageName is "Example", then the collection will be Example-0@2x.png, Example-1@2x.png, etc.
    - parameter animations: An optional closure containing the animations to sync with. Alternatively, you can call this function with nil animations and it will record all activity on the view which performed the call for the specified duration. The default value is nil.
    - parameter completion: An optional closure which acts as an entry point for chaining recordings in order to split up a long, complex animation into several sub-animations. A Bool parameter contains the state of whether or not the recording was successful. The default value is nil.
    */
    final public func snapshotsWithDuration(duration: CFTimeInterval, imageName: String, animations: (() -> Void)? = nil, completion: ((finished: Bool) -> Void)? = nil) {
        if duration <= 0 {
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        let documentsDirectoryURLs = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let imageDirectoryURL = documentsDirectoryURLs.URLByAppendingPathComponent(imageName)
        
        // Attempt to remove any existing image directory so that a fresh new recording is always saved.
        do { try fileManager.removeItemAtURL(imageDirectoryURL) } catch {}
        
        do {
            try fileManager.createDirectoryAtURL(imageDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            self.imageDocumentsURL = imageDirectoryURL
            self.imageName = imageName
            self.snapshotNumber = 0
            self.duration = CACurrentMediaTime() + duration
            self.completionHolder = CompletionHolder(completion: completion)
            let displayLink = CADisplayLink(target: self, selector: "takeSnapshot:")
            animations?()
            displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        }
        catch {
            print("\n[KFWatchKitAnimations] Failed to create directory '\(imageName)': \(error)\n")
            completion?(finished: false)
        }
    }
    
    final internal func takeSnapshot(displayLink: CADisplayLink) {
        if displayLink.timestamp > self.duration {
            displayLink.invalidate()
            print("\n[KFWatchKitAnimations] Finished writing '\(self.imageName)' to the filesystem.\n")
            print("\n[KFWatchKitAnimations] \(self.imageDocumentsURL.path!)\n")
            self.completionHolder.completion?(finished: true)
        }
        else if self.snapshotNumber > 1024 {
            displayLink.invalidate()
            print("\n[KFWatchKitAnimations] This animation has exceeded the maximum number of images WatchKit will allow. As a work-around, please record the sub-animations individually.\n")
            self.completionHolder.completion?(finished: false)
        }
        else if let imagePath = self.imageDocumentsURL.URLByAppendingPathComponent("\(self.imageName)-\(self.snapshotNumber)@2x.png").path, snapshotImage = UIImagePNGRepresentation(self.snapshot()) {
            snapshotImage.writeToFile(imagePath, atomically: true)
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
