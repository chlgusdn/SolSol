//
//  HomeExpenseChartView.swift
//  SolSol
//
//  Created by NUNU:D on 10/5/25.
//

import SwiftUI
import Charts
import DesignSystem

public struct HomeExpenseChartView: View {
    @ObservedObject private var viewModel: HomeExpenseChartViewModel

    public init(viewModel: HomeExpenseChartViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack(spacing: 10) {
            Chart(viewModel.entries) { item in
                BarMark(
                    x: .value(
                        item.label,
                        item.x
                    )
                )
                .foregroundStyle(item.color)
            }
            .cornerRadius(8)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color(SDColors.graph500 ?? .systemGray3))
                    .cornerRadius(8)
            }
            .chartXAxis(.hidden)
            .chartXScale(domain: 0...viewModel.maxCount)
            .chartYScale(range: .plotDimension(endPadding: -8))
            .chartLegend(position: .bottom, spacing: 8)
            .chartLegend(.visible)
            .frame(height: 50)
            
            customLegend
        }
        
    }
    
    private var customLegend: some View {
        HStack(spacing: 6) {
            
            ForEach(viewModel.entries) { item in
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 10, height: 10)
                    
                    Text(item.label)
                        .font(Font(SDFont.pixel(size: 10).font))
                        .foregroundStyle(Color(SDColors.black100 ?? .black))
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    Text("HomeExpenseChartView Preview")
}
