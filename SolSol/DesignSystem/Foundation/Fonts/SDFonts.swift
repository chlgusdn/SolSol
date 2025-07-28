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
            return UIFont(
                name: "Mone-Pixel",
                size: CGFloat(size)
            )!
            
        case .round(let size):
            return UIFont(
                name: "Mone-Regular",
                size: CGFloat(size)
            )!
        }
    }
}
