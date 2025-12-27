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
import Factory

/// 홈화면
final class HomeViewController: BaseViewController {

    private let scrollView = UIScrollView()
    
    private let scrollContentView = SDView()
        .setBackgroundColor(color: .white300)
    
    private lazy var summaryView = HomeExpenseSummaryView()
        .setParentViewController(to: self)
        .setBackgroundColor(color: .white100)
        .setRadius(radius: 20)
    
    private let eventContainerView = SDView()
        .setRadius(radius: 4)
    
    private let statisticsScreenButton = SDImageButton()
        .setBackgroundColor(color: .white100)
        .setImage(image: .icTrendingUp, padding: 10, position: .top)
        .setText(text: .mainEventButtonStatsticsTitle)
        .setTextColor(color: .black100)
        .setFont(font: .pixel(size: 10))
        .setSubTitle(text: .mainEventButtonStatsticsSubTitle)
        .setSubTitleFont(font: .pixel(size: 18))
        .setSubTitleTextColor(color: .black100)
        .setRadius(radius: 8)
        .setHighlightColor(color: .gray80)
        .onTapped {
            Log.d("Statistics")
        }
    
    private let zeroExpenseDayScreenButton = SDImageButton()
        .setBackgroundColor(color: .white100)
        .setImage(image: .icDollarSign, padding: 10, position: .top)
        .setText(text: .mainEventButtonZeroexpenseDayTitle)
        .setTextColor(color: .black100)
        .setFont(font: .pixel(size: 10))
        .setSubTitle(text: .mainEventButtonZeroexpenseDaySubTitle)
        .setSubTitleFont(font: .pixel(size: 18))
        .setSubTitleTextColor(color: .black100)
        .setRadius(radius: 8)
        .setHighlightColor(color: .gray80)
        .onTapped {
            Log.d("zeroExpenseDay")
        }
    
    private let todayIncomePercentContainerView = SDView()
        .setBackgroundColor(color: .white100)
        .setRadius(radius: 4)
    
    private let todayDateLabel = SDLabel()
        .setFont(font: .pixel(size: 16))
        .setTextColor(color: .black100)
        .setNumberOfLines(limitLine: 1)
        .setText(text: Date().toString(for: LocalizedStringResource.commonDateFormatYmdE.localized))
    
    private let percentLabel = SDCountingLabel()
        .setDuration(1)
        .setFont(font: .pixel(size: 16))
        .setTextColor(color: .graph300)
    
    private lazy var expenseCalendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.locale = .current
        calendar.layer.cornerRadius = 8
        calendar.scrollEnabled = true
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.appearance.weekdayFont = SDFont.pixel(size: 14).font
        calendar.appearance.titleFont = SDFont.pixel(size: 14).font
        calendar.backgroundColor = .white100
        calendar.appearance.headerTitleFont = SDFont.pixel(size: 16).font
        calendar.allowsMultipleSelection = false
        calendar.appearance.caseOptions = .headerUsesCapitalized
        calendar.appearance.weekdayTextColor = .gray400
        calendar.appearance.titlePlaceholderColor = .gray400
        calendar.appearance.headerTitleColor = .gray800
        return calendar
    }()
    
    @Injected(\.homeViewModel) var viewModel: HomeViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        .setTextColor(color: .graph300)
                        .registerTextFormat { text in
                            return LocalizedStringResource.commonIncreaesPercent(text).localized
                        }
                        .isHidden = false
                    
                    self.percentLabel.startAnimation()
                        
                case .decrease(let rate):
                    self.percentLabel
                        .setRange(start: 0.0, end: rate)
                        .setTextColor(color: .danger100)
                        .registerTextFormat { text in
                            return LocalizedStringResource.commonDecreaesPercent(text).localized
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
        self.scrollView.backgroundColor = .white200
        self.view.backgroundColor = .white200
    }
    
    private func setupScrollContentContainerView() {
        self.scrollContentView
            .flex
            .direction(.column)
            .gap(10)
            .justifyContent(.spaceBetween)
            .backgroundColor(.white200)
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
            .backgroundColor(.white200)
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
            .backgroundColor(.white100)
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
