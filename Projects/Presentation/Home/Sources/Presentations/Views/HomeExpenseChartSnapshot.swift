//
//  HomeExpenseChartSnapshot.swift
//  SolSol
//
//  Created by NUNU:D on 4/9/26.
//

import UIKit
import DesignSystem

/// 홈 화면 지출 요약 내용 snap shot
struct HomeExpenseChartSnapshot {
    
    struct Item {
        let id: UUID
        let label: String
        let color: UIColor
        let value: Double
    }

    let items: [Item]
    let totalValue: Double

    init(entries: [SDChartDataEntry]) {
        self.items = entries.map { entry in
            Item(
                id: entry.id,
                label: entry.label,
                color: entry.color,
                value: max(entry.x, 0)
            )
        }
        
        self.totalValue = self.items.reduce(0) { partialResult, item in
            partialResult + item.value
        }
    }

    func segmentFrames(in bounds: CGRect) -> [CGRect] {
        guard totalValue > 0, bounds.width > 0, bounds.height > 0 else {
            return []
        }

        var frames: [CGRect] = []
        var xOffset = bounds.minX

        for (index, item) in items.enumerated() {
            let width: CGFloat

            if index == items.indices.last {
                width = max(bounds.maxX - xOffset, 0)
            } else {
                width = bounds.width * CGFloat(item.value / totalValue)
            }

            let frame = CGRect(
                x: xOffset,
                y: bounds.minY,
                width: width,
                height: bounds.height
            )

            frames.append(frame)
            xOffset += width
        }

        return frames
    }
}
