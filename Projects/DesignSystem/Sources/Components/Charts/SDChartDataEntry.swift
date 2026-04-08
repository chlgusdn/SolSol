//
//  SDChartDataEntry.swift
//  SolSol
//
//  Created by NUNU:D on 10/5/25.
//

import UIKit

public struct SDChartDataEntry: Identifiable {
    public let id = UUID()
    public let label: String
    public let color: UIColor
    public let x: Double
    public let y: Double

    public init(
        label: String,
        color: UIColor,
        x: Double,
        y: Double
    ) {
        self.label = label
        self.color = color
        self.x = x
        self.y = y
    }
}
