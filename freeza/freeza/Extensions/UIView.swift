//
//  UIView.swift
//  Sidebar Menu
//
//  Created by Sushil Rathaur on 09/06/20.
//  Copyright © 2020 AppCodeZip. All rights reserved.
//

import UIKit

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }

    class func loadNib() -> Self {
        return loadNib(self)
    }

    @available(iOS 10.0, *)
    func shakev1(speed: TimeInterval = 0.85, offset: CGFloat = 10, completion: (() -> Void)? = nil) {
        let time = 1.0 * speed - 0.15
        let timeFactor = CGFloat(time / 4)
        let animationDelays = [timeFactor, timeFactor * 2, timeFactor * 3]

        let shakeAnimator = UIViewPropertyAnimator(duration: time, dampingRatio: 0.3)
        shakeAnimator.addAnimations {
            self.transform = CGAffineTransform(translationX: offset, y: 0)
        }
        shakeAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: -offset, y: 0)
        }, delayFactor: animationDelays[0])
        shakeAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: offset, y: 0)
        }, delayFactor: animationDelays[1])
        shakeAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: animationDelays[2])
        shakeAnimator.startAnimation()

        shakeAnimator.addCompletion { _ in
            completion?()
        }

        shakeAnimator.startAnimation()
    }

    func shakev2(count: Float = 4, for duration: TimeInterval = 0.5, withTranslation translation: Float = 5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count
        animation.duration = duration / TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}
