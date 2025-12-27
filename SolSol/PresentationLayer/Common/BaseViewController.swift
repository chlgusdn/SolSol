//
//  BaseViewController.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit

/// 베이스로 사용될 뷰 컨트롤러
class BaseViewController: UIViewController, Layoutable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.d("\(self) Start")
        self.view.backgroundColor = .white400
        self.setupProperties()
        self.setupViews()
    }
    
    func setupViews() {}
    
    func setupProperties() {}
    
    func setupLayout() {}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupLayout()
    }
}
