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
    
    private lazy var expenseSummaryButton = SDImageButton()
        .setBackgroundColor(color: .white100)
        .setRadius(radius: 8)
        .setText(text: .mainSummaryExpenseTitle(self.viewModel.summaryExpenseDays))
        .setTextColor(color: .black100)
        .setFont(font: .pixel(size: 14))
        .setHighlightColor(color: .gray80)
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
        .onTapped {
            Log.d("Summary")
        }
    
    private lazy var summaryTitleLabel = SDCountingLabel()
        .setFont(font: .pixel(size: 20))
        .setDuration(3)
        .setRange(
            start: 0,
            end: self.viewModel.totalExpense
        )
        .setTextColor(color: .black100)
        .setAnimationOption(option: .linear)
        .registerTextFormat { format in
            return LocalizedStringResource.mainSummaryAmount(format).localized
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
    
    private let viewModel = HomeExpenseSummaryViewModel()
    
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
        self.setupChartFlexLayout()
    }
    
    func setupLayout() {
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout(mode: .fitContainer)
    }
    
    func setupProperties() {}
    
    func setupBindings() {}
    
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
                
                if let chartView = chartView {
                    flex.addItem(chartView)
                        .marginTop(11)
                        .height(50)
                }
                
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
