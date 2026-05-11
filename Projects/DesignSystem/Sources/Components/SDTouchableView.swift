//
//  SDTouchableView.swift
//  SolSol
//
//  Created by NUNU:D on 8/28/25.
//

import UIKit

public class SDTouchableView: UIControl, DampingAnimation {

    private var viewTapAction: (() -> Void)?

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.performPressAnimation()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.performReleaseAnimation()
        self.performHapticFeedback()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.performReleaseAnimation()
        self.performHapticFeedback()
    }

    public func setBackgroundColor(color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    public func setRadius(
        radius: CGFloat,
        corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    ) -> Self {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        return self
    }

    public func setBorder(width: CGFloat, color: UIColor) -> Self {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        return self
    }

    public func onTapped(action: @escaping () -> Void) {
        self.viewTapAction = action
        self.addTarget(self, action: #selector(tappedAction), for: .touchUpInside)
    }

    @objc private func tappedAction() {
        self.viewTapAction?()
    }
}
