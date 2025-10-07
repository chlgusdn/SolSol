//
//  HomeViewController.swift
//  SolSol
//
//  Created by NUNU:D on 9/1/25.
//

import UIKit
import PinLayout
import FlexLayout

/// 홈화면
final class HomeViewController: BaseViewController {

    private let scrollView = UIScrollView()
    
    private let scrollContentView = SDView()
        .setBackgroundColor(color: .white300)
    
    private lazy var summaryView = HomeExpenseSummaryView()
        .setParentViewController(to: self)
        .setBackgroundColor(color: .white100)
        .setRadius(radius: 4)
    
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
        .setRange(start: 0, end: 10)
        .setFont(font: .pixel(size: 16))
        .setTextColor(color: .graph300)
        .registerTextFormat {
            return "+\($0)%"
        }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.percentLabel.startAnimation()
    }
    
    override func setupViews() {
        super.setupViews()
        
        self.scrollView.addSubview(self.scrollContentView)
        self.view.addSubview(self.scrollView)
        
        self.setupEventContainerView()
        self.setupDateContainerView()
        self.setupScrollContentContainerView()
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
                    .margin(0, 20, 20, 20)
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
