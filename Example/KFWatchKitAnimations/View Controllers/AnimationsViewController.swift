//
//  Created by Kiavash Faisali on 2015-02-17.
//  Copyright (c) 2016 Kiavash Faisali. All rights reserved.
//

import UIKit

final class AnimationsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var watchView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var heroCenterYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var watchKitAnimationsCenterYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var watchKitAnimationsLabel: UILabel!
    
    var circle: CAShapeLayer!
    var animation: CABasicAnimation!
    var counter = 5
    var shouldFadeOut = false
    let attributedString = NSMutableAttributedString(string: "KFWatchKitAnimations")
    var currentCharacterLocation = 0
    
    // MARK: - Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Status Bar Methods
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Always make sure the background of the view you're recording is set to clearColor, unless you really intend to keep the background with it.
        self.watchView.backgroundColor = UIColor.clearColor()
        // If your background color is clearColor, you should set opaque to false for better performance during recording.
        self.watchView.opaque = false
        
        self.visualEffectView.layer.cornerRadius = self.visualEffectView.bounds.size.width / 2
        self.heroImageView.layer.cornerRadius = self.heroImageView.bounds.size.width / 2
        
        self.circle = CAShapeLayer()
        self.circle.path = UIBezierPath(arcCenter: CGPointMake(self.watchView.bounds.width/2, self.watchView.bounds.height/2), radius: 50, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(3.0 * M_PI_2), clockwise: true).CGPath
        self.circle.fillColor = nil
        self.circle.strokeColor = UIColor(red: 180/255.0, green: 1.0, blue: 167/255.0, alpha: 1.0).CGColor
        self.circle.lineWidth = 2
        
        self.animation = CABasicAnimation(keyPath: "strokeEnd")
        self.animation.duration = 2
        self.animation.fromValue = 0
        self.animation.toValue = 1
        self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // ANIMATION CHAIN PHASE 1: DRAW GREEN CIRCLE
        self.watchView.snapshotsWithDuration(self.animation.duration, imageName: "drawGreenCircle", animations: {
            self.circle.addAnimation(self.animation, forKey: "circleAnimation")
            self.watchView.layer.addSublayer(self.circle)
        }) { finished in
            // ANIMATION CHAIN PHASE 2: COUNTDOWN FROM 5 AND FADE OUT BLUR
            self.watchView.snapshotsWithDuration(7.7, imageName: "countdownAndRemoveBlur", animations: {
                let duration = 0.7
                
                self.countdownAnimationWithSequenceDuration(duration) {
                    UIView.animateWithDuration(duration, animations: {
                        self.visualEffectView.alpha = 0.0
                        self.circle.removeFromSuperlayer()
                        self.heroImageView.layer.borderWidth = 1.0
                        self.heroImageView.layer.borderColor = UIColor(red: 170/255.0, green: 211/255.0, blue: 1.0, alpha: 1.0).CGColor
                    }) { finished in
                        self.visualEffectView.removeFromSuperview()
                    }
                }
            }) { finished in
                // ANIMATION CHAIN PHASE 3: PLACE IMAGE AT THE TOP AND SLIDE IN TITLE FROM UNDERNEATH WHILE FADING IN.
                self.watchView.snapshotsWithDuration(1.0, imageName: "verticalShiftAndFadeIn", animations: {
                    self.heroCenterYAlignmentConstraint.constant = 30
                    self.watchKitAnimationsCenterYAlignmentConstraint.constant = -35
                    
                    UIView.animateWithDuration(1.0, animations: {
                        self.watchView.layoutIfNeeded()
                        self.watchKitAnimationsLabel.alpha = 1.0
                    })
                }) { finished in
                    // Kick off the text refresh beforehand and simply record the view without passing in any animations to the closure.
                    NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "refreshText", userInfo: nil, repeats: true)
                    
                    // ANIMATION CHAIN PHASE 4: INFINITE YELLOW CHARACTER JUMP
                    self.watchView.snapshotsWithDuration(3.0, imageName: "yellowCharacterJump")
                }
            }
        }
    }
    
    // MARK: - Miscellaneous Methods
    func countdownAnimationWithSequenceDuration(duration: NSTimeInterval, completion: (() -> Void)? = nil) {
        UIView.animateWithDuration(duration, animations: {
            if self.shouldFadeOut {
                self.countdownLabel.alpha = 0.1
            }
            else {
                self.countdownLabel.alpha = 1.0
                self.countdownLabel.text = "\(self.counter)"
            }
        }) { finished in
            if finished {
                self.shouldFadeOut = !self.shouldFadeOut
                if self.shouldFadeOut == false {
                    --self.counter
                }
                
                if self.counter > 0 {
                    self.countdownAnimationWithSequenceDuration(duration, completion: completion)
                }
                else {
                    completion?()
                }
            }
        }
    }
    
    func refreshText() {
        let previousCharacterLocation = (self.currentCharacterLocation - 1 + self.attributedString.length) % self.attributedString.length
        
        self.attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.yellowColor(), range: NSMakeRange(self.currentCharacterLocation, 1))
        self.attributedString.removeAttribute(NSForegroundColorAttributeName, range: NSMakeRange(previousCharacterLocation, 1))
        self.watchKitAnimationsLabel.attributedText = self.attributedString
        
        self.currentCharacterLocation = (self.currentCharacterLocation + 1) % self.attributedString.length
    }
}
