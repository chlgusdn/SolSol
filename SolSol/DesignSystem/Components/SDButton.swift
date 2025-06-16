//
//  SDButton.swift
//  SDS
//
//  Created by CareMedi on 4/30/25.
//

import UIKit

public final class SDButton: UIButton {
    
    private var disabledColor: UIColor = .lightGray
    
    private var buttonTapAction: (() -> Void)?
    
    public var isDisabled: Bool = false {
        didSet {
            self.isEnabled = !isDisabled
            self.backgroundColor = isDisabled == true ? disabledColor : self.backgroundColor
        }
    }
    
    public func setBackgroundColor(color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    public func setDisabledColor(color: UIColor) -> Self {
        self.disabledColor = color
        return self
    }
    
    public func setFont(font: SDFont) -> Self {
        self.titleLabel?.font = font.font
        return self
    }
    
    public func setRadius(radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        return self
    }
    
    public func setTextColor(color: UIColor, for state: State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    
    public func setText(text: String, for state: State = .normal) -> Self {
        setTitle(text, for: state)
        return self
    }
    
    public func registerButtonAction(action: @escaping () -> Void) {
        self.buttonTapAction = action
        self.addTarget(self, action: #selector(buttonTappedAction), for: .touchUpInside)
    }
    
    @objc private func buttonTappedAction() {
        buttonTapAction?()
    }
}
