//
//  HapticFeedbackAnimation.swift
//  SolSol
//
//  Created by NUNU:D on 10/8/25.
//

import UIKit

public protocol HapticFeedbackAnimation: UIView {
    func performHapticInLight()
    func performHapticInMedium()
    func performHapticInDanger()
}

extension HapticFeedbackAnimation {

    public func performHapticInLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    public func performHapticInMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    public func performHapticInDanger() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

}
