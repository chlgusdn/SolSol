//
//  HomeViewController.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit
import PinLayout
import FlexLayout

/// 홈화면
final class HomeViewController: BaseViewController {

    private let testLabel = SDLabel()
        .setFont(font: .pixel(size: 55))
        .setText(text: "안녕하세요 반갑")
        .setTextColor(color: .graph300)
        .setNumberOfLines(limitLine: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViews() {
        super.setupViews()
    }
    
    override func setupLayout() {
        super.setupLayout()
    }
}
