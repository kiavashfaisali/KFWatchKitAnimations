//
//  InterfaceController.swift
//  WatchKitAnimations WatchKit Extension
//
//  Created by Kiavash Faisali on 2015-02-17.
//  Copyright (c) 2015 Kiavash Faisali. All rights reserved.
//

import WatchKit

final class InterfaceController: WKInterfaceController {
    // MARK: - Properties
    @IBOutlet weak var animationImage: WKInterfaceImage!

    // MARK: - Setup and Teardown
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    // MARK: - View Lifecycle
    override func willActivate() {
        super.willActivate()
        
        let drawCircleDuration = 2.0
        self.animationImage.setImageNamed("drawGreenCircle-")
        self.animationImage.startAnimatingWithImagesInRange(NSMakeRange(0, 96), duration: drawCircleDuration, repeatCount: 1)
        
        self.dispatchAnimationsAfterSeconds(drawCircleDuration) {
            let countdownDuration = 7.7
            self.animationImage.setImageNamed("countdownAndRemoveBlur-")
            self.animationImage.startAnimatingWithImagesInRange(NSMakeRange(0, 460), duration: countdownDuration, repeatCount: 1)
            
            self.dispatchAnimationsAfterSeconds(countdownDuration) {
                let verticalShiftDuration = 1.0
                self.animationImage.setImageNamed("verticalShiftAndFadeIn-")
                self.animationImage.startAnimatingWithImagesInRange(NSMakeRange(0, 58), duration: verticalShiftDuration, repeatCount: 1)
                
                self.dispatchAnimationsAfterSeconds(verticalShiftDuration) {
                    let yellowCharacterDuration = 2.0
                    self.animationImage.setImageNamed("yellowCharacterJump-")
                    self.animationImage.startAnimatingWithImagesInRange(NSMakeRange(0, 122), duration: yellowCharacterDuration, repeatCount: 0)
                }
            }
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    // MARK: - Miscellaneous Methods
    func dispatchAnimationsAfterSeconds(seconds: Double, animations: () -> Void) {
        if seconds <= 0.0 {
            return
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.animationImage.stopAnimating()
            animations()
        }
    }
}
