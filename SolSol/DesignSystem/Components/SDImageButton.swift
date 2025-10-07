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
    
    private var buttonBackgroundColor: UIColor = .white100
    
    private var buttonTapAction: (() -> Void)?
    
    public override var isHighlighted: Bool {
        didSet {
            self.configuration?.background.backgroundColor = isHighlighted ?
            self.highlightColor :
            self.buttonBackgroundColor
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
        config.background.backgroundColor = color
        self.configuration = config
        self.buttonBackgroundColor = color
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
        var config = configuration ?? UIButton.Configuration.plain()
        config.background.cornerRadius = radius
        configuration = config
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
        
        config.title = String(localized: text)
        
        self.configuration = config
        
        return self
    }
    
    public func setPadding(inset: NSDirectionalEdgeInsets) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        config.contentInsets = inset
        configuration = config
        return self
    }
    
    @discardableResult
    public func onTapped(action: @escaping () -> Void) -> Self {
        self.buttonTapAction = action
        self.addTarget(self, action: #selector(buttonTappedAction), for: .touchUpInside)
        return self
    }
    
    @discardableResult
    public func setSubTitle(text: LocalizedStringResource) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        config.subtitle = String(localized: text)
        self.configuration = config
        return self
    }
    
    @discardableResult
    public func setSubTitleFont(font: SDFont) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        let previousTransformer = config.subtitleTextAttributesTransformer
        
        config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = previousTransformer?(incoming) ?? incoming
            outgoing.font = font.font
            return outgoing
        }
        
        self.configuration = config
        return self
    }
    
    @discardableResult
    public func setSubTitleTextColor(color: UIColor) -> Self {
        var config = configuration ?? UIButton.Configuration.plain()
        let previousTransformer = config.subtitleTextAttributesTransformer
        
        config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = previousTransformer?(incoming) ?? incoming
            outgoing.foregroundColor = color
            return outgoing
        }
        
        self.configuration = config
        
        return self
    }
    
    @objc private func buttonTappedAction() {
        buttonTapAction?()
    }

}
