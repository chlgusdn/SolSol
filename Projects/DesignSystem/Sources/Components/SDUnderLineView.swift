//
//  SDUnderLineView.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit

public final class SDUnderLineView: UIView {

    init(backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
