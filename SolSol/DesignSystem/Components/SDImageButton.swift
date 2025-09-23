//
//  SDImageButton.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit

public final class SDImageButton: UIButton, DampingAnimation {

    private var disabledColor: UIColor = .lightGray
    
    private var highlightColor: UIColor = .white70
    
    private var buttonTapAction: (() -> Void)?
    
    public override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.highlightColor : self.configuration?.baseBackgroundColor
        }
    }
    
    public var isDisabled: Bool = false {
        didSet {
            self.isEnabled = !isDisabled
            self.backgroundColor = isDisabled == true ? disabledColor : self.backgroundColor
        }
    }
    
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
    
    public func setImage(image: UIImage, padding: CGFloat, position: NSDirectionalRectEdge) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        config.imagePlacement = position
        config.image = image
        config.imagePadding = padding
        self.configuration = config
        return self
    }
    
    public func setBackgroundColor(color: UIColor) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        config.baseBackgroundColor = color
        return self
    }
    
    public func setHighlightColor(color: UIColor) -> Self {
        self.highlightColor = color
        return self
    }
    
    public func setDisabledColor(color: UIColor) -> Self {
        self.disabledColor = color
        return self
    }
    
    public func setRadius(radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        return self
    }
    
    public func setFont(font: SDFont) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        let previousTransformer = config.titleTextAttributesTransformer
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = previousTransformer?(incoming) ?? incoming
            outgoing.font = font.font
            return outgoing
        }
        
        self.configuration = config
        return self
    }
    
    public func setTextColor(color: UIColor) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        let previousTransformer = config.titleTextAttributesTransformer
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = previousTransformer?(incoming) ?? incoming
            outgoing.foregroundColor = color
            return outgoing
        }
        
        self.configuration = config
        
        return self
    }
    
    public func setText(text: LocalizedStringResource) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        
        config.title = NSLocalizedString(
            text.key,
            tableName: text.table,
            comment: ""
        )
        
        self.configuration = config
        
        return self
    }
    
    public func setPadding(inset: NSDirectionalEdgeInsets) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        config.contentInsets = inset
        configuration = config
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
