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
    final fileprivate class CompletionHolder {
        let completion: ((_ finished: Bool) -> Void)?
        
        init(completion: ((Bool) -> Void)?) {
            self.completion = completion
        }
    }
    
    final fileprivate var duration: CFTimeInterval! {
        get {
            return objc_getAssociatedObject(self, &durationAssociationKey) as? CFTimeInterval
        }
        set {
            objc_setAssociatedObject(self, &durationAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final fileprivate var imageDocumentsURL: URL! {
        get {
            return objc_getAssociatedObject(self, &imageDocumentsURLAssociationKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &imageDocumentsURLAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final fileprivate var imageName: String! {
        get {
            return objc_getAssociatedObject(self, &imageNameAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &imageNameAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final fileprivate var snapshotNumber: Int! {
        get {
            return objc_getAssociatedObject(self, &snapshotNumberAssociationKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &snapshotNumberAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    final fileprivate var completionHolder: CompletionHolder! {
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
        - parameter imageName: `String` representing the name of the image collection (as well as the sub-folder in Documents). Do not add a "-" at the end as that will already be appended. For example, if `imageName` is "Example", then the collection will be `Example-0@2x.png`, `Example-1@2x.png`, etc.
        - parameter animations: An optional closure containing the animations to sync with. Alternatively, you can call this function with `nil` animations and it will record all activity on the view which performed the call for the specified duration. The default value is `nil`.
        - parameter completion: An optional closure which acts as an entry point for chaining snapshots in order to split up a long, complex animation into several sub-animations. A Bool parameter contains the state of whether or not the recording was successful. The default value is `nil`.
    */
    final public func snapshots(duration: CFTimeInterval, imageName: String, animations: (() -> Void)? = nil, completion: ((_ success: Bool) -> Void)? = nil) {
        guard duration > 0 else {
            print("\n[KFWatchKitAnimations] Failed to begin snapshots. Please ensure that `duration` is a positive value.")
            completion?(false)
            
            return
        }
        
        let fileManager = FileManager.default
        let imageDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(imageName)
        
        // Attempt to remove any existing image directory so that a fresh new recording is always saved.
        try? fileManager.removeItem(at: imageDirectoryURL)
        
        do {
            try fileManager.createDirectory(at: imageDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            self.imageDocumentsURL = imageDirectoryURL
            self.imageName = imageName
            self.snapshotNumber = 0
            self.duration = CACurrentMediaTime() + duration
            self.completionHolder = CompletionHolder(completion: completion)
            
            let displayLink = CADisplayLink(target: self, selector: #selector(UIView.takeSnapshot(displayLink:)))
            animations?()
            displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
        catch {
            print("\n[KFWatchKitAnimations] Failed to create directory '\(imageName)': \(error)\n")
            completion?(false)
        }
    }
    
    @objc final internal func takeSnapshot(displayLink: CADisplayLink) {
        if displayLink.timestamp > self.duration {
            displayLink.invalidate()
            
            print("\n[KFWatchKitAnimations] Finished writing '\(self.imageName!)' to the filesystem.\n")
            print("\n[KFWatchKitAnimations] \(self.imageDocumentsURL!.path)\n")
            
            self.completionHolder.completion?(true)
        }
        else if self.snapshotNumber > 1024 {
            displayLink.invalidate()
            
            print("\n[KFWatchKitAnimations] This animation has exceeded the maximum number of images WatchKit will allow. As a work-around, please record the sub-animations individually.\n")
            
            self.completionHolder.completion?(false)
        }
        else if let snapshotImageData = UIImagePNGRepresentation(self.snapshot()) {
            let imagePath = self.imageDocumentsURL.appendingPathComponent("\(self.imageName!)-\(self.snapshotNumber!)@2x.png").path
            let imageURL = URL(fileURLWithPath: imagePath)
            
            do {
                try snapshotImageData.write(to: imageURL, options: .atomic)
            }
            catch {
                print("\n[KFWatchKitAnimations] Failed to write data to url: \(imageURL), due to error: \(error)")
                
                self.completionHolder.completion?(false)
            }
            
            self.snapshotNumber! += 1
        }
    }
    
    final fileprivate func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return snapshotImage!
    }
}
