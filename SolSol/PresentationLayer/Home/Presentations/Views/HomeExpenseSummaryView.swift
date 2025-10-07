//
//  HomeExpenseSummaryView.swift
//  SolSol
//
//  Created by NUNU:D on 9/2/25.
//

import UIKit
import FlexLayout
import PinLayout

final class HomeExpenseSummaryView: SDView, Layoutable {
    
    public weak var parentViewController: UIViewController?
    
    private let expenseSummaryButton = SDImageButton()
        .setBackgroundColor(color: .white100)
        .setRadius(radius: 8)
        .setText(text: .mainSummaryExpenseTitle(1))
        .setTextColor(color: .black100)
        .setFont(font: .pixel(size: 14))
        .setHighlightColor(color: .lightGray.withAlphaComponent(0.2))
        .setPadding(
            inset: NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
        )
        .setImage(
            image: .icArrowRight,
            padding: 0,
            position: .trailing
        )
    
    private let summaryTitleLabel = SDCountingLabel()
        .setFont(font: .pixel(size: 20))
        .setDuration(interval: 3)
        .setRange(start: 0, end: 10_000_000)
        .setAnimationOption(option: .linear)
        .registerTextFormat { format in
            return String(localized: LocalizedStringResource.mainSummaryAmount(format))
        }
    
    private lazy var chartView: UIView? = {
        
        guard let parentViewController = parentViewController else {
            return nil
        }
        
        return HomeExpenseChartView()
            .toUIKitView(for: parentViewController)
    }()
    
    private let incomeButton = SDButton()
        .setBackgroundColor(color: .primary200)
        .setText(text: .commonButtonAddIncome)
        .setFont(font: .pixel(size: 18))
        .setTextColor(color: .white100)
        .setRadius(radius: 8)
        .onTapped {
            Log.d("InCome")
        }
    
    private let expenseButton = SDButton()
        .setBackgroundColor(color: .danger70)
        .setText(text: .commonButtonAddExpense)
        .setFont(font: .pixel(size: 18))
        .setTextColor(color: .white100)
        .setRadius(radius: 8)
        .onTapped {
            Log.d("Expense")
        }
    
    private let containerView = SDView()
        .setBackgroundColor(color: .white100)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupProperties()
        self.setupBindings()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupLayout()
        self.summaryTitleLabel.startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.addSubview(containerView)
    }
    
    func setupLayout() {
        containerView.pin.all(pin.safeArea)
        
        containerView.flex.define { flex in
            flex.direction(.column)
                .alignItems(.start)
                .paddingHorizontal(16)
            
            flex.addItem(expenseSummaryButton)
                .marginTop(10)
                .marginLeft(-8)
            
            flex.addItem(summaryTitleLabel)
                .marginTop(11)
            
            if let chartView = chartView {
                flex.addItem(chartView)
                    .marginTop(11)
            }
            
            flex.addItem()
                .direction(.row)
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
        .layout(mode: .fitContainer)
    }
    
    func setupProperties() {}
    
    func setupBindings() {}
    
    @discardableResult
    public func setParentViewController(to viewController: UIViewController) -> Self {
        self.parentViewController = viewController
        return self
    }
}

#Preview {
    class PreviewContainer: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            let expenseView = HomeExpenseSummaryView()
                .setParentViewController(to: self)
            view.addSubview(expenseView)
            expenseView.pin.all()
        }
    }
    
    return PreviewContainer()
}
