//
//  Created by Kiavash Faisali on 2015-02-17.
//  Copyright (c) 2016 Kiavash Faisali. All rights reserved.
//

import UIKit
import KFWatchKitAnimations

final class AnimationsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var watchView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var heroCenterYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var heroWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var watchKitAnimationsCenterYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var watchKitAnimationsLabel: UILabel!
    @IBOutlet weak var watchViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var watchViewHeightConstraint: NSLayoutConstraint!
    
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
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Always make sure the background of the view you're recording is set to clearColor, unless you really intend to keep the background with it.
        self.watchView.backgroundColor = UIColor.clear
        // If your background color is clearColor, you should set opaque to false for better performance during recording.
        self.watchView.isOpaque = false
        
        self.visualEffectView.layer.cornerRadius = self.heroWidthConstraint.constant / 2
        self.heroImageView.layer.cornerRadius = self.heroWidthConstraint.constant / 2
        
        self.circle = CAShapeLayer()
        self.circle.path = UIBezierPath(arcCenter: CGPoint(x: self.watchViewWidthConstraint.constant/2, y: self.watchViewHeightConstraint.constant/2), radius: 50, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(3.0 * M_PI_2), clockwise: true).cgPath
        self.circle.fillColor = nil
        self.circle.strokeColor = UIColor(red: 180/255.0, green: 1.0, blue: 167/255.0, alpha: 1.0).cgColor
        self.circle.lineWidth = 2
        
        self.animation = CABasicAnimation(keyPath: "strokeEnd")
        self.animation.duration = 2
        self.animation.fromValue = 0
        self.animation.toValue = 1
        self.animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /* BEGIN ANIMATION CHAIN PHASE 1: DRAW GREEN CIRCLE */
        self.watchView.snapshots(duration: self.animation.duration, imageName: "drawGreenCircle", animations: {
            self.circle.add(self.animation, forKey: "circleAnimation")
            self.watchView.layer.addSublayer(self.circle)
        /* END ANIMATION CHAIN PHASE 1 */
        }) { success in
            /* BEGIN ANIMATION CHAIN PHASE 2: COUNTDOWN FROM 5 AND FADE OUT BLUR */
            self.watchView.snapshots(duration: 7.7, imageName: "countdownAndRemoveBlur", animations: {
                let sequenceDuration = 0.7
                
                self.countdownAnimation(sequenceDuration: sequenceDuration) {
                    UIView.animate(withDuration: sequenceDuration, animations: {
                        self.visualEffectView.alpha = 0.0
                        self.circle.removeFromSuperlayer()
                        self.heroImageView.layer.borderWidth = 1.0
                        self.heroImageView.layer.borderColor = UIColor(red: 170/255.0, green: 211/255.0, blue: 1.0, alpha: 1.0).cgColor
                    }) { _ in
                        self.visualEffectView.removeFromSuperview()
                    }
                }
            /* END ANIMATION CHAIN PHASE 2 */
            }) { _ in
                /* BEGIN ANIMATION CHAIN PHASE 3: PLACE IMAGE AT THE TOP AND SLIDE IN TITLE FROM UNDERNEATH WHILE FADING IN */
                self.watchView.snapshots(duration: 1.0, imageName: "verticalShiftAndFadeIn", animations: {
                    self.heroCenterYAlignmentConstraint.constant = 30
                    self.watchKitAnimationsCenterYAlignmentConstraint.constant = -35
                    
                    UIView.animate(withDuration: 1.0, animations: {
                        self.watchView.layoutIfNeeded()
                        self.watchKitAnimationsLabel.alpha = 1.0
                    })
                }) { _ in
                    // Kick off the text refresh beforehand and simply record the view without passing in any animations to the closure.
                    Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(AnimationsViewController.refreshText), userInfo: nil, repeats: true)
                    
                    // ANIMATION CHAIN PHASE 4: INFINITE YELLOW CHARACTER JUMP
                    self.watchView.snapshots(duration: 3.0, imageName: "yellowCharacterJump")
                }
                /* END ANIMATION CHAIN PHASE 3 */
            }
        }
    }
    
    // MARK: - Miscellaneous Methods
    func countdownAnimation(sequenceDuration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: sequenceDuration, animations: {
            if self.shouldFadeOut {
                self.countdownLabel.alpha = 0.1
            }
            else {
                self.countdownLabel.alpha = 1.0
                self.countdownLabel.text = "\(self.counter)"
            }
        }) { _ in
            self.shouldFadeOut = !self.shouldFadeOut
            
            if !self.shouldFadeOut {
                self.counter -= 1
            }
            
            if self.counter > 0 {
                self.countdownAnimation(sequenceDuration: sequenceDuration, completion: completion)
            }
            else {
                completion?()
            }
        }
    }
    
    func refreshText() {
        let previousCharacterLocation = (self.currentCharacterLocation - 1 + self.attributedString.length) % self.attributedString.length
        
        self.attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.yellow, range: NSMakeRange(self.currentCharacterLocation, 1))
        self.attributedString.removeAttribute(NSForegroundColorAttributeName, range: NSMakeRange(previousCharacterLocation, 1))
        self.watchKitAnimationsLabel.attributedText = self.attributedString
        
        self.currentCharacterLocation = (self.currentCharacterLocation + 1) % self.attributedString.length
    }
}
