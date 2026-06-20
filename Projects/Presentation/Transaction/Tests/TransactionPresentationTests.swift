import Testing
import Foundation
import UIKit
import DesignSystem
@testable import TransactionPresentation

struct TransactionPresentationTests {
    @Test
    @MainActor
    func incomeInitialStateProvidesIncomeUIValues() async throws {
        let viewModel = TransactionInputViewModel(initialType: .income)

        #expect(viewModel.type == .income)
        #expect(viewModel.amountPrefixText == "+")
        #expect(viewModel.ctaTitle == "수익 추가")
        #expect(viewModel.isTagButtonHidden == true)
        #expect(viewModel.headerColor.isEqual(SDColors.primary200 ?? .systemGreen))
        #expect(viewModel.ctaColor.isEqual(SDColors.primary200 ?? .systemGreen))
    }

    @Test
    @MainActor
    func expenseInitialStateProvidesExpenseUIValues() async throws {
        let viewModel = TransactionInputViewModel(initialType: .expense)

        #expect(viewModel.type == .expense)
        #expect(viewModel.amountPrefixText == "-")
        #expect(viewModel.ctaTitle == "지출 추가")
        #expect(viewModel.isTagButtonHidden == false)
        #expect(viewModel.headerColor.isEqual(SDColors.danger70 ?? .systemRed))
        #expect(viewModel.ctaColor.isEqual(SDColors.danger70 ?? .systemRed))
    }

    @Test
    @MainActor
    func toggleTypeSwitchesBetweenIncomeAndExpense() async throws {
        let viewModel = TransactionInputViewModel(initialType: .income)

        viewModel.toggleType()

        #expect(viewModel.type == .expense)
        #expect(viewModel.amountPrefixText == "-")
        #expect(viewModel.ctaTitle == "지출 추가")
        #expect(viewModel.isTagButtonHidden == false)

        viewModel.toggleType()

        #expect(viewModel.type == .income)
        #expect(viewModel.amountPrefixText == "+")
        #expect(viewModel.ctaTitle == "수익 추가")
        #expect(viewModel.isTagButtonHidden == true)
    }

    @Test
    @MainActor
    func selectedDateUsesKoreanTwelveHourFormat() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(
            calendar.date(
                from: DateComponents(
                    timeZone: TimeZone(identifier: "Asia/Seoul"),
                    year: 2025,
                    month: 3,
                    day: 4,
                    hour: 23,
                    minute: 52
                )
            )
        )

        let viewModel = TransactionInputViewModel(initialType: .expense, selectedDate: date)

        #expect(viewModel.dateText == "2025년 03월 04일 오후 11시 52분")
    }

    @Test
    @MainActor
    func transactionInputVCUpdatesAmountSlotWhenAmountTextFieldChanges() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .income)
        )

        viewController.loadViewIfNeeded()

        let amountTextField = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? UITextField }
                .first { $0.keyboardType == .numberPad }
        )
        let amountSlotView = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDSlotAmountView }
                .first
        )

        amountTextField.text = "34567"
        amountTextField.sendActions(for: .editingChanged)
        amountSlotView.layoutIfNeeded()

        #expect(amountSlotView.accessibilityLabel == "34,567")
    }

    @Test
    @MainActor
    func transactionInputVCScalesAmountFontDownForLongAmounts() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .income)
        )

        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        viewController.view.layoutIfNeeded()

        let amountTextField = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? UITextField }
                .first { $0.keyboardType == .numberPad }
        )
        let prefixLabel = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDLabel }
                .first { $0.text == "+" }
        )
        let currencyLabel = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDLabel }
                .first { $0.text == "₩" }
        )
        let initialPrefixPointSize = prefixLabel.font.pointSize
        let initialCurrencyPointSize = currencyLabel.font.pointSize

        amountTextField.text = "1234567890123"
        amountTextField.sendActions(for: .editingChanged)
        viewController.view.layoutIfNeeded()

        #expect(prefixLabel.font.pointSize < initialPrefixPointSize)
        #expect(currencyLabel.font.pointSize < initialCurrencyPointSize)
    }

    @Test
    @MainActor
    func transactionInputVCCentersAmountTokensWithPrefixAttachedAndCurrencyFixed() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .expense)
        )

        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        viewController.view.layoutIfNeeded()

        let amountTextField = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? UITextField }
                .first { $0.keyboardType == .numberPad }
        )
        let amountSlotView = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDSlotAmountView }
                .first
        )
        let amountContainerView = try #require(amountSlotView.superview)
        let tokenStackView = try #require(
            amountSlotView.subviews
                .compactMap { $0 as? UIStackView }
                .first
        )
        let prefixLabel = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDLabel }
                .first { $0.text == "-" }
        )
        let currencyLabel = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDLabel }
                .first { $0.text == "₩" }
        )

        amountTextField.text = "12000"
        amountTextField.sendActions(for: .editingChanged)
        viewController.view.layoutIfNeeded()
        amountSlotView.layoutIfNeeded()

        let tokenFrame = tokenStackView.convert(tokenStackView.bounds, to: amountContainerView)
        let prefixGap = tokenFrame.minX - prefixLabel.frame.maxX

        #expect(abs(currencyLabel.frame.maxX - amountContainerView.bounds.width) < 1)
        #expect(abs(tokenFrame.midX - amountContainerView.bounds.midX) < 1)
        #expect(prefixLabel.frame.minX > 1)
        #expect(prefixGap > 0)
        #expect(prefixGap < 8)
    }

    @Test
    @MainActor
    func transactionInputVCDoesNotProvideCustomBackButtonForSwipeNavigation() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .income)
        )

        viewController.loadViewIfNeeded()

        let backButton = allSubviews(in: viewController.view)
            .compactMap { $0 as? UIButton }
            .first { $0.accessibilityIdentifier == "transactionInput.backButton" }

        #expect(backButton == nil)
    }

    @Test
    @MainActor
    func transactionCoordinatorStartKeepsNavigationHiddenAndEnablesSwipeBack() async throws {
        let rootViewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        let coordinator = TransactionCoordinator(
            navigationController: navigationController,
            dependencies: StubTransactionDependencies(),
            initialType: .income
        )

        navigationController.interactivePopGestureRecognizer?.isEnabled = false

        coordinator.start()

        #expect(navigationController.isNavigationBarHidden == true)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
        #expect(navigationController.viewControllers.count == 2)
    }

    @Test
    @MainActor
    func transactionInputVCRegistersBackgroundTapGestureForKeyboardDismissal() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .income)
        )

        viewController.loadViewIfNeeded()

        let backgroundTapGesture = viewController.view.gestureRecognizers?
            .compactMap { $0 as? UITapGestureRecognizer }
            .first { $0.name == "transactionInput.backgroundTap" }

        #expect(backgroundTapGesture != nil)
        #expect(backgroundTapGesture?.cancelsTouchesInView == false)
    }

    @Test
    @MainActor
    func transactionInputVCMovesCTAAboveKeyboardForTitleInputWithBottomSafeArea() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .income)
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        viewController.loadViewIfNeeded()
        viewController.additionalSafeAreaInsets.bottom = 34
        viewController.view.frame = window.bounds
        viewController.view.layoutIfNeeded()

        let titleTextField = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? UITextField }
                .first { $0.attributedPlaceholder?.string == "제목을 입력하세요" }
        )
        let ctaButton = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDButton }
                .first
        )
        let keyboardFrame = CGRect(x: 0, y: 552, width: 393, height: 300)

        _ = titleTextField.becomeFirstResponder()
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: keyboardFrame,
                UIResponder.keyboardAnimationDurationUserInfoKey: 0.0,
                UIResponder.keyboardAnimationCurveUserInfoKey: UInt(UIView.AnimationCurve.linear.rawValue)
            ]
        )
        viewController.view.layoutIfNeeded()

        #expect(ctaButton.frame.maxY <= keyboardFrame.minY)
    }

    @Test
    @MainActor
    func transactionInputVCUsesScrollViewForWholeContent() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .income)
        )

        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        viewController.view.layoutIfNeeded()

        let scrollView = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? UIScrollView }
                .first { $0.accessibilityIdentifier == "transactionInput.scrollView" }
        )
        let headerView = try #require(
            scrollView.subviews
                .flatMap(allSubviews(in:))
                .first { $0.subviews.contains { $0 is SDSlotAmountView } }
        )

        #expect(scrollView.frame.minY == 0)
        #expect(headerView.frame.minY == 0)
        #expect(scrollView.contentSize.height >= scrollView.bounds.height)
    }

    @Test
    @MainActor
    func transactionInputVCResizesWholeScrollViewAboveKeyboardCTA() async throws {
        let viewController = TransactionInputVC(
            viewModel: TransactionInputViewModel(initialType: .income)
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        viewController.loadViewIfNeeded()
        viewController.view.frame = window.bounds
        viewController.view.layoutIfNeeded()

        let scrollView = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? UIScrollView }
                .first { $0.accessibilityIdentifier == "transactionInput.scrollView" }
        )
        let ctaButton = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? SDButton }
                .first
        )
        let titleTextField = try #require(
            allSubviews(in: viewController.view)
                .compactMap { $0 as? UITextField }
                .first { $0.attributedPlaceholder?.string == "제목을 입력하세요" }
        )
        let keyboardFrame = CGRect(x: 0, y: 552, width: 393, height: 300)

        _ = titleTextField.becomeFirstResponder()
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: keyboardFrame,
                UIResponder.keyboardAnimationDurationUserInfoKey: 0.0,
                UIResponder.keyboardAnimationCurveUserInfoKey: UInt(UIView.AnimationCurve.linear.rawValue)
            ]
        )
        viewController.view.layoutIfNeeded()

        #expect(scrollView.frame.maxY <= ctaButton.frame.minY)
        #expect(scrollView.contentSize.height > scrollView.bounds.height)
    }

    @Test
    @MainActor
    func transactionCoordinatorCloseInputReturnsToHomeRootAndKeepsNavigationHidden() async throws {
        let rootViewController = UIViewController()
        let pushedViewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        let coordinator = TransactionCoordinator(
            navigationController: navigationController,
            dependencies: StubTransactionDependencies(),
            initialType: .income
        )

        navigationController.pushViewController(pushedViewController, animated: false)
        navigationController.isNavigationBarHidden = false

        coordinator.closeInput(animated: false)

        #expect(navigationController.topViewController === rootViewController)
        #expect(navigationController.isNavigationBarHidden == true)
    }
}

private func allSubviews(in view: UIView) -> [UIView] {
    view.subviews + view.subviews.flatMap(allSubviews(in:))
}

private final class StubTransactionDependencies: TransactionDependencyProviding {
    func makeTransactionInputViewModel(initialType: TransactionInputType) -> TransactionInputViewModel {
        TransactionInputViewModel(initialType: initialType)
    }
}
