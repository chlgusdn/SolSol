//
//  HomeExpenseBarCanvasView.swift
//  SolSol
//
//  Created by NUNU:D on 4/9/26.
//

import UIKit
import DesignSystem

/// 홈 화면 지출 요약 바 화면 (카테고리 바)
final class HomeExpenseBarCanvasView: UIView {

    private enum LayoutMetrics {
        static let cornerRadius: CGFloat = 8
    }

    private let trackLayer = CALayer()
    private var segmentLayers: [CALayer] = []
    private var snapshot = HomeExpenseChartSnapshot(entries: [])

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.render()
    }

    func apply(snapshot: HomeExpenseChartSnapshot) {
        self.snapshot = snapshot
        self.setNeedsLayout()
    }

    private func setupLayers() {
        self.layer.cornerRadius = LayoutMetrics.cornerRadius
        self.layer.masksToBounds = true
        self.trackLayer.backgroundColor = (SDColors.graph500 ?? .systemGray3).cgColor
        self.layer.addSublayer(trackLayer)
    }

    private func render() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        self.trackLayer.frame = self.bounds
        self.syncSegmentLayers(count: self.snapshot.items.count)

        let frames = self.snapshot.segmentFrames(in: self.bounds)

        for (index, layer) in self.segmentLayers.enumerated() {

            guard index < self.snapshot.items.count, index < frames.count else {
                layer.frame = .zero
                layer.isHidden = true
                continue
            }

            layer.isHidden = false
            layer.frame = frames[index]
            layer.backgroundColor = self.snapshot.items[index].color.cgColor
        }

        CATransaction.commit()
    }

    private func syncSegmentLayers(count: Int) {

        while self.segmentLayers.count < count {
            let layer = CALayer()
            self.layer.addSublayer(layer)
            self.segmentLayers.append(layer)
        }

        while self.segmentLayers.count > count {
            self.segmentLayers.removeLast().removeFromSuperlayer()
        }
    }
}
