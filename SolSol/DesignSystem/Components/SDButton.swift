//
//  SDButton.swift
//  SDS
//
//  Created by CareMedi on 4/30/25.
//

import UIKit

public final class SDButton: UIButton, DampingAnimation {
    
    private var disabledColor: UIColor = .lightGray
    
    private var buttonTapAction: (() -> Void)?
    
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
    
    public func setBackgroundColor(color: UIColor) -> Self {
        var config = configuration ?? UIButton.Configuration.filled()
        config.baseBackgroundColor = color
        configuration = config
        return self
    }
    
    public func setDisabledColor(color: UIColor) -> Self {
        self.disabledColor = color
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
    
    public func setRadius(radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
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
    
    public func onTapped(action: @escaping () -> Void) -> Self {
        self.buttonTapAction = action
        self.addTarget(self, action: #selector(buttonTappedAction), for: .touchUpInside)
        return self
    }
    
    public func setPadding(inset: NSDirectionalEdgeInsets) -> Self {
        var config = configuration ?? UIButton.Configuration.filled()
        config.contentInsets = inset
        configuration = config
        return self
    }
    
    @objc private func buttonTappedAction() {
        self.buttonTapAction?()
    }
}


#Preview(traits: .defaultLayout, body: {
    SDButton()
        .setBackgroundColor(color: UIColor.primary100)
        .setText(text: "안녕하세요. 반갑습니다.")
        .setTextColor(color: .white200)
        .setFont(font: .pixel(size: 50))
        .setRadius(radius: 10)
        .setPadding(inset: .init(top: 10, leading: 10, bottom: 10, trailing: 10))
        .onTapped {
            print("hello")
        }
})
