//
//  Layoutable.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit

/// UIView Layout 정형화 프로토콜
public protocol Layoutable: UIResponder {

    /// 레이아웃 append 설정
    func setupViews()

    /// 레이아웃 Pin/Flex 레이아웃 설정
    func setupLayout()

    /// 프로퍼티 설정
    func setupProperties()
}
