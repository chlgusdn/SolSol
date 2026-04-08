//
//  SDLabel.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit

public final class SDLabel: UILabel {

    public func setFont(font: SDFont) -> Self {
        self.font = font.font
        return self
    }

    public func setTextColor(color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    public func setText(localized text: LocalizedStringResource) -> Self {
        self.text = String(localized: text)
        return self
    }

    public func setText(text: String) -> Self {
        self.text = text
        return self
    }

    public func setNumberOfLines(limitLine: Int) -> Self {
        self.numberOfLines = limitLine
        return self
    }

}
