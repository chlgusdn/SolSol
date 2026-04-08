//
//  HomeExpenseChartLegendView.swift
//  SolSol
//
//  Created by NUNU:D on 4/9/26.
//

import UIKit
import FlexLayout
import PinLayout
import DesignSystem

/// 홈 화면 지출 요약 범례 화면 
final class HomeExpenseChartLegendView: UIView {
    private enum LayoutMetrics {
        static let itemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 8
        static let dotSize: CGFloat = 10
        static let dotCornerRadius: CGFloat = 5
        static let dotLabelSpacing: CGFloat = 6
        static let fallbackWidth: CGFloat = 320
    }

    private let contentView = UIView()
    private var items: [HomeExpenseChartSnapshot.Item] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(contentView)
        self.rebuildLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView
            .pin
            .all()
        
        self.contentView
            .flex
            .layout(mode: .adjustHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard !self.items.isEmpty else {
            return .zero
        }

        let width = if size.width > 0 {
            size.width
        } else if self.bounds.width > 0 {
            self.bounds.width
        } else {
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

    override var intrinsicContentSize: CGSize {
        let fittedSize = self.sizeThatFits(
            CGSize(
                width: self.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            )
        )

        return CGSize(width: UIView.noIntrinsicMetric, height: fittedSize.height)
    }

    func apply(snapshot: HomeExpenseChartSnapshot) {
        self.items = snapshot.items
        self.isHidden = snapshot.items.isEmpty
        self.rebuildLayout()
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
    }

    private func rebuildLayout() {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }

        self.contentView
            .flex
            .direction(.row)
            .wrap(.wrap)
            .alignItems(.center)
            .columnGap(LayoutMetrics.itemSpacing)
            .rowGap(LayoutMetrics.lineSpacing)
            .define { flex in
                for item in self.items {
                    let dotView = UIView()
                    dotView.backgroundColor = item.color
                    dotView.layer.cornerRadius = LayoutMetrics.dotCornerRadius

                    let label = UILabel()
                    label.text = item.label
                    label.font = SDFont.pixel(size: 10).font
                    label.textColor = SDColors.black100 ?? .black

                    flex.addItem()
                        .direction(.row)
                        .alignItems(.center)
                        .columnGap(LayoutMetrics.dotLabelSpacing)
                        .define { flex in
                            
                            flex.addItem(dotView)
                                .width(LayoutMetrics.dotSize)
                                .height(LayoutMetrics.dotSize)
                            
                            flex.addItem(label)
                        }
                }
            }
    }
}
