//
//  SDChartDataEntry.swift
//  SolSol
//
//  Created by NUNU:D on 10/5/25.
//

import SwiftUI

public struct SDChartDataEntry: Identifiable {
    public let id = UUID()
    public let label: String
    public let color: Color
    public let x: Double
    public let y: Double

    public init(label: String, color: Color, x: Double, y: Double) {
        self.label = label
        self.color = color
        self.x = x
        self.y = y
    }
}
