//
//  TransactionInputViewModel.swift
//  TransactionPresentation
//
//  Created by Codex on 6/20/26.
//

import Foundation
import UIKit
import DesignSystem

public enum TransactionInputType: Equatable {
    case income
    case expense
}

public final class TransactionInputViewModel: ObservableObject {

    @Published public private(set) var type: TransactionInputType
    @Published public private(set) var selectedDate: Date

    public var amountPrefixText: String {
        switch type {
        case .income:
            return "+"
        case .expense:
            return "-"
        }
    }

    public var ctaTitle: String {
        switch type {
        case .income:
            return "수익 추가"
        case .expense:
            return "지출 추가"
        }
    }

    public var headerColor: UIColor {
        switch type {
        case .income:
            return SDColors.primary200 ?? .systemGreen
        case .expense:
            return SDColors.danger70 ?? .systemRed
        }
    }

    public var ctaColor: UIColor {
        headerColor
    }

    public var isTagButtonHidden: Bool {
        type == .income
    }

    public var dateText: String {
        Self.dateFormatter.string(from: selectedDate)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy년 MM월 dd일 a h시 mm분"
        return formatter
    }()

    public init(initialType: TransactionInputType, selectedDate: Date = Date()) {
        self.type = initialType
        self.selectedDate = selectedDate
    }

    public func toggleType() {
        switch type {
        case .income:
            type = .expense
        case .expense:
            type = .income
        }
    }

    public func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }
}
