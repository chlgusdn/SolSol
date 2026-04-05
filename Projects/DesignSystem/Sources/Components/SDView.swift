//
//  SDView.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit

open class SDView: UIView {

    public func setBackgroundColor(color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    public func setRadius(radius: CGFloat, corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) -> Self {
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
