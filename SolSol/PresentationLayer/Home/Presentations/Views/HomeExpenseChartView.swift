//
//  HomeExpenseChartView.swift
//  SolSol
//
//  Created by NUNU:D on 10/5/25.
//

import SwiftUI
import Charts

public struct HomeExpenseChartView: View {
    
    private(set)var entries: [SDChartDataEntry] = []
    private var yAxisMaxValue: Double = 100
    
    public var body: some View {
        
        VStack(spacing: 10) {
            Chart(entries) { item in
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
                    .background(Color(.graph500))
                    .cornerRadius(8)
            }
            .chartXAxis(.hidden)
            .chartXScale(domain: 0...yAxisMaxValue)
            .chartYScale(range: .plotDimension(endPadding: -8))
            .chartLegend(position: .bottom, spacing: 8)
            .chartLegend(.visible)
            .frame(height: 50)
            
            customLegend
        }
        
    }
    
    private var customLegend: some View {
        HStack(spacing: 6) {
            
            ForEach(entries) { item in
                HStack(spacing: 6) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 10, height: 10)
                    
                    Text(item.label)
                        .font(Font(SDFont.pixel(size: 10).font))
                        .foregroundStyle(.black100)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    HomeExpenseChartView()
}
