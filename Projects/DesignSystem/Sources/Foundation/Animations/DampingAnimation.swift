//
//  DampingAnimation.swift
//  SolSol
//
//  Created by NUNU:D on 8/16/25.
//

import UIKit

public protocol DampingAnimation: UIView {
    var animationDuration: TimeInterval { get }
    var damping: CGFloat { get }
    var velocity: CGFloat { get }

    func performPressAnimation()
    func performReleaseAnimation()
    func performHapticFeedback()
}

extension DampingAnimation {

    public var animationDuration: TimeInterval {
        return 0.2
    }

    public var damping: CGFloat {
        return 0.7
    }

    public var velocity: CGFloat {
        return 0.5
    }

    public func performPressAnimation() {
        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.transform = CGAffineTransform(
                    scaleX: 0.95,
                    y: 0.95
                )
            }
        )
    }

    public func performReleaseAnimation() {
        UIView.animate(
            withDuration: self.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: self.damping,
            initialSpringVelocity: self.velocity,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: {
                self.transform = .identity
            }
        )
    }

    public func performHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}
