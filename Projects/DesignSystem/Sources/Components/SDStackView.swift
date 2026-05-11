//
//  SDStackView.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit

public final class SDStackView: UIStackView {

    init(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat) {
        super.init(frame: .zero)
        self.axis = axis
        self.distribution = distribution
        self.spacing = spacing
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addingArrangeSubViews(views: [UIView]) {
        views.forEach { self.addArrangedSubview($0) }
    }

    public func setPadding(inset: UIEdgeInsets) -> Self {
        self.layoutMargins = inset
        self.isLayoutMarginsRelativeArrangement = true
        return self
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

}
