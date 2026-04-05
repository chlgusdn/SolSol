//
//  UIView+Extension.swift
//  SolSol
//
//  Created by NUNU:D on 10/5/25.
//

import SwiftUI

public extension View {
    
    func toUIKitView(for viewController: UIViewController) -> UIView {
        let hostingController = UIHostingController(rootView: self)
        hostingController.view.backgroundColor = .clear
        viewController.addChild(hostingController)
        return hostingController.view
    }
}
