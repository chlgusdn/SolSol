//
//  SDFonts.swift
//  SolSol
//
//  Created by NUNU:D on 6/3/25.
//

import UIKit

/// SolSol Fonts
public enum SDFont {
    case pixel(size: Int)
    case round(size: Int)

    public var font: UIFont {
        switch self {
            
        case .pixel(let size):
            return DesignSystemFontFamily.머니그라피Ttf.pixel.font(size: CGFloat(size))
            
        case .round(let size):
            return DesignSystemFontFamily.머니그라피Ttf.rounded.font(size: CGFloat(size))
        }
    }
}
