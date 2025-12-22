//
//  HomeChartSummaryResponseModel.swift
//  SolSol
//
//  Created by NUNU:D on 12/22/25.
//

import Foundation

public struct HomeChartSummaryResponseModel {
    /// 최대 값
    var max: Int
    /// 차트 엔트리 배열
    var entries: [SDChartDataEntry]
}
