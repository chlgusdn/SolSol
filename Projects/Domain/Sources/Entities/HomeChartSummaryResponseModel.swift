//
//  HomeChartSummaryResponseModel.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation

public struct HomeChartSummaryEntryModel: Sendable {
    public let label: String
    public let colorName: String
    public let value: Double

    public init(label: String, colorName: String, value: Double) {
        self.label = label
        self.colorName = colorName
        self.value = value
    }
}

public struct HomeChartSummaryResponseModel {
    /// 최대 값
    public let max: Int
    /// 차트 엔트리 배열
    public let entries: [HomeChartSummaryEntryModel]

    public init(max: Int, entries: [HomeChartSummaryEntryModel]) {
        self.max = max
        self.entries = entries
    }
}
