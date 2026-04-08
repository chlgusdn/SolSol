//
//  SDImageView.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit

public final class SDImageView: UIImageView {

    init(image: UIImage, contentMode: UIView.ContentMode) {
        super.init(frame: .zero)
        self.image = image
        self.contentMode = contentMode
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setopacity(opacity: Float) -> Self {
        self.layer.opacity = opacity
        return self
    }

    public func setRadius(radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        return self
    }

}
