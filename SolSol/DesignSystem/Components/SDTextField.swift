//
//  SDTextField.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit
import Combine

@available(iOS 13.0, *)
public final class SDTextField: UITextField {

    @Published private(set) var textPublisher: String?
    
    private var bindings = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .compactMap(\.text)
            .sink { self.textPublisher = $0 }
            .store(in: &bindings)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setBorder(width: CGFloat, color: UIColor) -> Self {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        return self
    }
    
    public func setPlaceholder(placeholder: LocalizedStringResource) -> Self {
        self.placeholder = String(localized: placeholder)
        return self
    }
    
    public func setKeyboardType(type: UIKeyboardType) -> Self {
        self.keyboardType = type
        return self
    }
    
    public func setFont(font: SDFont) -> Self {
        self.font = font.font
        return self
    }
    
    public func setTextColor(color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    deinit {
        bindings.removeAll()
    }
}
