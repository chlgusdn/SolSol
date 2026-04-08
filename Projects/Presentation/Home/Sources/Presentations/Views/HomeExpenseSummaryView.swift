//
//  HomeExpenseSummaryView.swift
//  SolSol
//
//  Created by NUNU:D on 9/2/25.
//

import UIKit
import FlexLayout
import PinLayout
import SolSolCore
import DesignSystem

final class HomeExpenseSummaryView: SDView {
    private let viewModel: HomeExpenseSummaryViewModel

    public weak var parentViewController: UIViewController?

    private lazy var expenseSummaryButton = SDImageButton()
        .setBackgroundColor(color: SDColors.white100 ?? .white)
        .setRadius(radius: 8)
        .setText(text: Self.summaryExpenseTitle(self.viewModel.summaryExpenseDays))
        .setTextColor(color: SDColors.black100 ?? .black)
        .setFont(font: .pixel(size: 14))
        .setHighlightColor(color: SDColors.gray80 ?? .systemGray4)
        .setPadding(
            inset: NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
        )
        .setImage(
            image: SDImages.icArrowRight,
            padding: 0,
            position: .trailing
        )
        .onTapped {
            Log.d("Summary")
        }

    private lazy var summaryTitleLabel = SDCountingLabel()
        .setFont(font: .pixel(size: 20))
        .setDuration(3)
        .setRange(
            start: 0,
            end: self.viewModel.totalExpense.doubleValue
        )
        .setTextColor(color: SDColors.black100 ?? .black)
        .setAnimationOption(option: .linear)
        .registerTextFormat { format in
            return "Total \(format) won"
        }

    private lazy var chartView = HomeExpenseChartView(viewModel: self.chartViewModel)

    private let incomeButton = SDButton()
        .setBackgroundColor(color: SDColors.primary200 ?? .systemGreen)
        .setText(text: "Add Income")
        .setFont(font: .pixel(size: 18))
        .setTextColor(color: SDColors.white100 ?? .white)
        .setRadius(radius: 8)
        .onTapped {
            Log.d("InCome")
        }

    private let expenseButton = SDButton()
        .setBackgroundColor(color: SDColors.danger70 ?? .systemRed)
        .setText(text: "Add Expense")
        .setFont(font: .pixel(size: 18))
        .setTextColor(color: SDColors.white100 ?? .white)
        .setRadius(radius: 8)
        .onTapped {
            Log.d("Expense")
        }

    private let containerView = SDView()
        .setBackgroundColor(color: SDColors.white100 ?? .white)

    private let chartViewModel: HomeExpenseChartViewModel

    init(viewModel: HomeExpenseSummaryViewModel, chartViewModel: HomeExpenseChartViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        self.chartViewModel = chartViewModel
        super.init(frame: frame)
        self.setupViews()
        self.setupProperties()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()

        //  지출 총 금액
        self.expenseSummaryButton.setText(
            text: Self.summaryExpenseTitle(self.viewModel.summaryExpenseDays)
        )

        // 지출 내역
        self.summaryTitleLabel
            .setRange(
                start: 0.0,
                end: self.viewModel.totalExpense.doubleValue
            )
            .startAnimation()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.addSubview(containerView)
        self.setupChartFlexLayout()
    }

    func setupLayout() {
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout(mode: .fitContainer)
    }

    func setupProperties() {}

    private func setupChartFlexLayout() {
        self.containerView
            .flex
            .paddingBottom(16)
            .paddingHorizontal(18)
            .direction(.column)
            .alignItems(.start)
            .define { flex in

                flex.addItem(expenseSummaryButton)
                    .marginTop(10)
                    .marginLeft(-8)

                flex.addItem(summaryTitleLabel)
                    .width(100%)
                    .marginTop(11)

                flex.addItem(chartView)
                    .marginTop(11)
                    .width(100%)

                flex.addItem()
                    .direction(.row)
                    .marginTop(10)
                    .justifyContent(.spaceBetween)
                    .columnGap(18)
                    .define { flex in
                        flex.addItem(incomeButton)
                            .grow(1)
                            .height(90)

                        flex.addItem(expenseButton)
                            .grow(1)
                            .height(90)

                    }
                    .width(100%)
            }
    }

    @discardableResult
    public func setParentViewController(to viewController: UIViewController) -> Self {
        self.parentViewController = viewController
        self.containerView.flex.markDirty()
        return self
    }

    private static func summaryExpenseTitle(_ days: Int) -> String {
        days == 0 ? "No recent expenses" : "Total spending (last \(days) days)"
    }
}
