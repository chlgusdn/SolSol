//
//  BaseViewController.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit
import Combine
import SolSolCore

/// 베이스로 사용될 뷰 컨트롤러
open class BaseViewController: UIViewController, Layoutable {

    public var bindings = Set<AnyCancellable>()

    open override func viewDidLoad() {
        super.viewDidLoad()
        Log.d("\(self) Start")
        self.view.backgroundColor = SDColors.white400 ?? .systemGray6
        self.setupProperties()
        self.setupViews()
        self.bind()
    }

    open func bind() {}

    open func setupViews() {}

    open func setupProperties() {}

    open func setupLayout() {}

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupLayout()
    }
}
