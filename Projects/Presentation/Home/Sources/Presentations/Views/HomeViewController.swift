//
//  HomeViewController.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit
import PinLayout
import FlexLayout
import FSCalendar
import SolSolCore
import DesignSystem

/// 홈화면
final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel
    private let summaryViewModel: HomeExpenseSummaryViewModel
    private let chartViewModel: HomeExpenseChartViewModel

    private let scrollView = UIScrollView()

    private let scrollContentView = SDView()
        .setBackgroundColor(color: SDColors.white300 ?? .systemGray5)

    private lazy var summaryView = HomeExpenseSummaryView(
        viewModel: self.summaryViewModel,
        chartViewModel: self.chartViewModel
    )
        .setParentViewController(to: self)
        .onIncomeTapped { [weak self] in
            self?.coordinator?.showIncomeInputScreen()
        }
        .onExpenseTapped { [weak self] in
            self?.coordinator?.showExpenseInputScreen()
        }
        .setBackgroundColor(color: SDColors.white100 ?? .white)
        .setRadius(radius: 20)

    private let eventContainerView = SDView()
        .setRadius(radius: 4)

    private lazy var statisticsScreenButton = SDImageButton()
        .setBackgroundColor(color: SDColors.white100 ?? .white)
        .setImage(image: SDImages.icTrendingUp, padding: 10, position: .top)
        .setText(text: "Stats")
        .setTextColor(color: SDColors.black100 ?? .black)
        .setFont(font: .pixel(size: 10))
        .setSubTitle(text: "How much this month?")
        .setSubTitleFont(font: .pixel(size: 18))
        .setSubTitleTextColor(color: SDColors.black100 ?? .black)
        .setRadius(radius: 8)
        .setHighlightColor(color: SDColors.gray80 ?? .systemGray4)
        .onTapped { }

    private let zeroExpenseDayScreenButton = SDImageButton()
        .setBackgroundColor(color: SDColors.white100 ?? .white)
        .setImage(image: SDImages.icDollarSign, padding: 10, position: .top)
        .setText(text: "Zero-Won Challenge")
        .setTextColor(color: SDColors.black100 ?? .black)
        .setFont(font: .pixel(size: 10))
        .setSubTitle(text: "Spend-Free Day")
        .setSubTitleFont(font: .pixel(size: 18))
        .setSubTitleTextColor(color: SDColors.black100 ?? .black)
        .setRadius(radius: 8)
        .setHighlightColor(color: SDColors.gray80 ?? .systemGray4)
        .onTapped {
            Log.d("zeroExpenseDay")
        }

    private let todayIncomePercentContainerView = SDView()
        .setBackgroundColor(color: SDColors.white100 ?? .white)
        .setRadius(radius: 4)

    private let todayDateLabel = SDLabel()
        .setFont(font: .pixel(size: 16))
        .setTextColor(color: SDColors.black100 ?? .black)
        .setNumberOfLines(limitLine: 1)
        .setText(text: Date().toString(for: "yyyy.MM.dd (E)"))

    private let percentLabel = SDCountingLabel()
        .setDuration(1)
        .setFont(font: .pixel(size: 16))
        .setTextColor(color: SDColors.graph300 ?? .systemGreen)

    private lazy var expenseCalendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.locale = .current
        calendar.layer.cornerRadius = 8
        calendar.scrollEnabled = true
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.appearance.weekdayFont = SDFont.pixel(size: 14).font
        calendar.appearance.titleFont = SDFont.pixel(size: 14).font
        calendar.backgroundColor = SDColors.white100 ?? .white
        calendar.appearance.headerTitleFont = SDFont.pixel(size: 16).font
        calendar.allowsMultipleSelection = false
        calendar.appearance.caseOptions = .headerUsesCapitalized
        calendar.appearance.weekdayTextColor = SDColors.gray400 ?? .systemGray
        calendar.appearance.titlePlaceholderColor = SDColors.gray400 ?? .systemGray
        calendar.appearance.headerTitleColor = SDColors.gray800 ?? .darkGray
        return calendar
    }()

    weak var coordinator: HomeCoordinator?

    init(
        viewModel: HomeViewModel,
        summaryViewModel: HomeExpenseSummaryViewModel,
        chartViewModel: HomeExpenseChartViewModel
    ) {
        self.viewModel = viewModel
        self.summaryViewModel = summaryViewModel
        self.chartViewModel = chartViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()

        self.scrollView.addSubview(self.scrollContentView)
        self.view.addSubview(self.scrollView)

        self.setupEventContainerView()
        self.setupDateContainerView()
        self.setupScrollContentContainerView()

        self.viewModel.$changeRate
            .sink { changeRate in
                switch changeRate {
                case .increase(let rate):
                    self.percentLabel
                        .setRange(start: 0.0, end: rate)
                        .setTextColor(color: SDColors.graph300 ?? .systemGreen)
                        .registerTextFormat { text in
                            return "+\(text) %"
                        }
                        .isHidden = false

                    self.percentLabel.startAnimation()

                case .decrease(let rate):
                    self.percentLabel
                        .setRange(start: 0.0, end: rate)
                        .setTextColor(color: SDColors.danger100 ?? .systemRed)
                        .registerTextFormat { text in
                            return "-\(text) %"
                        }
                        .isHidden = false

                    self.percentLabel.startAnimation()

                case .none:
                    self.percentLabel.isHidden = true
                }
            }
            .store(in: &self.bindings)
    }

    override func setupLayout() {
        super.setupLayout()

        self.scrollView
            .pin
            .all(self.view.pin.safeArea)

        self.scrollContentView
            .pin
            .top()
            .left()
            .width(scrollView.frame.width)

        self.scrollContentView
            .flex
            .layout(mode: .adjustHeight)

        self.scrollView.contentSize = scrollContentView.frame.size
    }

    override func setupProperties() {
        super.setupProperties()
        self.scrollView.backgroundColor = SDColors.white200 ?? .systemGray6
        self.view.backgroundColor = SDColors.white200 ?? .systemGray6
    }

    private func setupScrollContentContainerView() {
        self.scrollContentView
            .flex
            .direction(.column)
            .gap(10)
            .justifyContent(.spaceBetween)
            .backgroundColor(SDColors.white200 ?? .systemGray6)
            .define { flex in

                flex.addItem(summaryView)
                    .margin(10, 20, 10, 20)

                flex.addItem(eventContainerView)
                    .margin(0, 20, 4, 20)

                flex.addItem(todayIncomePercentContainerView)
                    .margin(0, 20, 0, 20)

                flex.addItem(expenseCalendar)
                    .padding(10)
                    .margin(4, 20, 20, 20)
                    .height(300)
                    .grow(1)
            }
    }

    private func setupEventContainerView() {
        self.eventContainerView
            .flex
            .direction(.row)
            .gap(10)
            .backgroundColor(SDColors.white200 ?? .systemGray6)
            .alignContent(.center)
            .define { flex in

                flex.addItem(self.zeroExpenseDayScreenButton)
                    .width(50%)

                flex.addItem(self.statisticsScreenButton)
                    .width(50%)
            }
    }

    private func setupDateContainerView() {
        self.todayIncomePercentContainerView
            .flex
            .direction(.row)
            .backgroundColor(SDColors.white100 ?? .white)
            .justifyContent(.start)
            .alignContent(.start)
            .paddingHorizontal(20)
            .paddingVertical(8)
            .gap(8)
            .define { flex in
                flex.addItem(self.todayDateLabel)
                flex.addItem(self.percentLabel)
                    .width(100%)
            }
    }
}
