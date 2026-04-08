//
//  HomeExpenseChartView.swift
//  SolSol
//
//  Created by NUNU:D on 10/5/25.
//

import UIKit
import Combine
import FlexLayout
import PinLayout

/// 홈 화면 지출 요약 차트
public final class HomeExpenseChartView: UIView {
    
    private enum LayoutMetrics {
        static let barHeight: CGFloat = 50
        static let legendTopSpacing: CGFloat = 10
        static let fallbackWidth: CGFloat = 320
    }

    private let contentView = UIView()
    private let barCanvasView = HomeExpenseBarCanvasView()
    private let legendView = HomeExpenseChartLegendView()

    private var snapshot = HomeExpenseChartSnapshot(entries: [])
    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: HomeExpenseChartViewModel) {
        super.init(frame: .zero)
        self.setupViews()
        self.bind(to: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView
            .pin
            .all()
        
        self.contentView
            .flex
            .layout(mode: .adjustHeight)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        // 현재 계산된 사이즈가 0이상인 경우는 계산된 사이즈로 표시
        let width = if size.width > 0 {
            size.width
        } else if self.bounds.width > 0 {
            // 계산된 사이즈가 0이라면 현재 view size return
            self.bounds.width
        } else {
            // view size도 0이라면 320 fall back
            LayoutMetrics.fallbackWidth
        }

        self.contentView
            .pin
            .top()
            .left()
            .width(width)
        
        self.contentView
            .flex
            .layout(mode: .adjustHeight)

        return CGSize(
            width: width,
            height: self.contentView.frame.height
        )
    }

    public override var intrinsicContentSize: CGSize {
        
        let fittedSize = self.sizeThatFits(
            CGSize(
                width: self.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            )
        )

        return CGSize(width: UIView.noIntrinsicMetric, height: fittedSize.height)
    }

    private func setupViews() {
        self.addSubview(contentView)
        self.rebuildLayout()
    }

    private func bind(to viewModel: HomeExpenseChartViewModel) {
        viewModel.$entries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.apply(snapshot: HomeExpenseChartSnapshot(entries: entries))
            }
            .store(in: &cancellables)
    }

    private func apply(snapshot: HomeExpenseChartSnapshot) {
        self.snapshot = snapshot
        self.barCanvasView.apply(snapshot: snapshot)
        self.legendView.apply(snapshot: snapshot)
        self.rebuildLayout()
        self.invalidateIntrinsicContentSize()
        self.superview?.flex.markDirty()
        self.setNeedsLayout()
    }

    private func rebuildLayout() {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }

        self.contentView
            .flex
            .direction(.column)
            .define { flex in
                flex.addItem(self.barCanvasView)
                    .width(100%)
                    .height(LayoutMetrics.barHeight)

                if !self.snapshot.items.isEmpty {
                    flex.addItem(self.legendView)
                        .width(100%)
                        .marginTop(LayoutMetrics.legendTopSpacing)
                }
            }
    }
}
