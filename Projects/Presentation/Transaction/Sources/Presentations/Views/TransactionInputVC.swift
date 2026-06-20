//
//  TransactionInputVC.swift
//  TransactionPresentation
//
//  Created by Codex on 6/20/26.
//

import UIKit
import Combine
import PinLayout
import DesignSystem

final class TransactionInputVC: BaseViewController, UITextViewDelegate, UIGestureRecognizerDelegate {

    private let viewModel: TransactionInputViewModel
    private var keyboardBottomInset: CGFloat = 0
    private var amountFontTier = AmountFontSizer.defaultTier

    private let headerView = SDView()
    private let amountContainerView = SDTouchableView()
    private let amountPrefixLabel = SDLabel()
        .setFont(font: .pixel(size: AmountFontSizer.defaultTier.prefixPointSize))
        .setTextColor(color: SDColors.white100 ?? .white)
        .setNumberOfLines(limitLine: 1)

    private lazy var amountSlotView = SDSlotAmountView()
        .setFont(font: .pixel(size: AmountFontSizer.defaultTier.amountPointSize))
        .setTextColor(color: SDColors.white100 ?? .white)
        .setPlaceholder(text: "0")

    private let currencyLabel = SDLabel()
        .setFont(font: .pixel(size: AmountFontSizer.defaultTier.amountPointSize))
        .setTextColor(color: SDColors.white100 ?? .white)
        .setText(text: "₩")
        .setNumberOfLines(limitLine: 1)

    private let amountTextField = UITextField()

    private lazy var tagButton = SDImageButton()
        .setBackgroundColor(color: SDColors.white70 ?? .white)
        .setImage(image: Self.symbolImage("tag"), padding: 0, position: .top)
        .setRadius(radius: 8)
        .setHighlightColor(color: SDColors.white100 ?? .white)
        .onTapped {}

    private lazy var toggleTypeButton = SDImageButton()
        .setBackgroundColor(color: SDColors.white70 ?? .white)
        .setImage(image: Self.symbolImage("arrow.triangle.2.circlepath"), padding: 0, position: .top)
        .setRadius(radius: 8)
        .setHighlightColor(color: SDColors.white100 ?? .white)
        .onTapped { [weak self] in
            self?.toggleTypeButtonTapped()
        }

    private let dateTextField = PaddedTextField()
    private let titleTextField = PaddedTextField()
    private let scrollView = UIScrollView()
    private let scrollContentView = SDView()
    private let memoTextView = UITextView()
    private let memoPlaceholderLabel = SDLabel()
        .setFont(font: .pixel(size: 16))
        .setTextColor(color: SDColors.gray80 ?? .lightGray)
        .setText(text: "내용을 입력하세요")

    private let datePicker = UIDatePicker()
    private lazy var backgroundTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        gesture.name = "transactionInput.backgroundTap"
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()

    private lazy var ctaButton = SDButton()
        .setTextColor(color: SDColors.white100 ?? .white)
        .setFont(font: .pixel(size: 20))
        .setRadius(radius: 8)
        .onTapped {}

    weak var coordinator: TransactionCoordinator?

    init(viewModel: TransactionInputViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(headerView)
        scrollContentView.addSubview(amountTextField)

        headerView.addSubview(amountContainerView)
        amountContainerView.addSubview(amountPrefixLabel)
        amountContainerView.addSubview(amountSlotView)
        amountContainerView.addSubview(currencyLabel)

        syncAmountSlotText()
        headerView.addSubview(tagButton)
        headerView.addSubview(toggleTypeButton)
        scrollContentView.addSubview(dateTextField)
        scrollContentView.addSubview(titleTextField)
        scrollContentView.addSubview(memoTextView)
        memoTextView.addSubview(memoPlaceholderLabel)
        view.addSubview(ctaButton)
    }

    override func setupLayout() {
        super.setupLayout()

        let metrics = LayoutMetrics(size: view.bounds.size)

        layoutForm(metrics: metrics)

        headerView.pin
            .top()
            .horizontally()
            .height(metrics.headerHeight)

        amountTextField.pin
            .top()
            .left()
            .width(1)
            .height(1)

        layoutAmountHeader(metrics: metrics)
        layoutScrollContent(metrics: metrics)
    }

    override func setupProperties() {
        super.setupProperties()

        view.backgroundColor = SDColors.white400 ?? .systemGray6
        configureAmountInput()
        configureDateInput()
        configureTextInputs()
        configureScrollView()
        configureBackgroundTapGesture()
        applyState(animated: false)
    }

    override func bind() {
        super.bind()

        viewModel.$selectedDate
            .receive(on: RunLoop.main)
            .sink { [weak self] date in
                guard let self else {
                    return
                }

                self.datePicker.date = date
                self.dateTextField.text = self.viewModel.dateText
            }
            .store(in: &bindings)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                self?.handleKeyboard(
                    notification: notification,
                    isVisible: true
                )
            }
            .store(in: &bindings)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.handleKeyboard(
                    notification: notification,
                    isVisible: false
                )
            }
            .store(in: &bindings)
    }

    func textViewDidChange(_ textView: UITextView) {
        memoPlaceholderLabel.isHidden = textView.text.isEmpty == false
    }

    private func layoutAmountHeader(metrics: LayoutMetrics) {
        let amountWidth = view.bounds.width - metrics.horizontalMargin * 2

        amountContainerView.pin
            .hCenter()
            .vCenter(-metrics.headerControlSize * 0.35)
            .width(amountWidth)
            .height(metrics.amountHeight)

        applyAmountFontTier(
            availableWidth: amountContainerView.bounds.width,
            spacing: metrics.amountSpacing
        )

        layoutAmountValue(metrics: metrics)
        layoutHeaderButtons(metrics: metrics)
    }

    private func layoutAmountValue(metrics: LayoutMetrics) {
        currencyLabel.pin
            .right()
            .vCenter()
            .sizeToFit()

        let amountSlotRight = currencyLabel.frame.minX - metrics.amountSpacing
        let amountSlotWidth = AmountFontSizer.centeredAmountWidth(
            for: amountTextField.text,
            prefix: viewModel.amountPrefixText,
            tier: amountFontTier,
            centerX: amountContainerView.bounds.midX,
            rightLimit: amountSlotRight,
            spacing: metrics.amountSpacing
        )

        amountSlotView.pin
            .top()
            .left(amountContainerView.bounds.midX - amountSlotWidth / 2)
            .width(amountSlotWidth)
            .height(metrics.amountHeight)

        let prefixSize = amountPrefixLabel.sizeThatFits(
            CGSize(width: amountContainerView.bounds.width, height: metrics.amountHeight)
        )

        amountPrefixLabel.pin
            .left(amountSlotView.frame.minX - metrics.amountSpacing - prefixSize.width)
            .vCenter()
            .width(prefixSize.width)
            .height(prefixSize.height)
    }

    private func layoutHeaderButtons(metrics: LayoutMetrics) {
        toggleTypeButton.pin
            .right(metrics.headerButtonMargin)
            .bottom(metrics.headerButtonMargin)
            .width(metrics.headerControlSize)
            .height(metrics.headerControlSize)

        if tagButton.isHidden {
            tagButton.frame = .zero
        } else {
            tagButton.pin
                .before(of: toggleTypeButton)
                .marginRight(metrics.headerButtonGap)
                .bottom(metrics.headerButtonMargin)
                .width(metrics.headerControlSize)
                .height(metrics.headerControlSize)
        }
    }

    private func layoutForm(metrics: LayoutMetrics) {
        ctaButton.pin
            .left(metrics.horizontalMargin)
            .right(metrics.horizontalMargin)
            .bottom(metrics.bottomMargin + keyboardBottomInset)
            .height(metrics.ctaHeight)

        scrollView.pin
            .top()
            .left()
            .right()
            .bottom(view.bounds.height - ctaButton.frame.minY + metrics.fieldGap)

        scrollContentView.pin
            .top()
            .left()
            .width(scrollView.bounds.width)

    }

    private func layoutScrollContent(metrics: LayoutMetrics) {
        dateTextField.pin
            .below(of: headerView)
            .marginTop(metrics.formTopMargin)
            .left(metrics.horizontalMargin)
            .right(metrics.horizontalMargin)
            .height(metrics.fieldHeight)

        titleTextField.pin
            .below(of: dateTextField)
            .marginTop(metrics.fieldGap)
            .left(metrics.horizontalMargin)
            .right(metrics.horizontalMargin)
            .height(metrics.fieldHeight)

        memoTextView.pin
            .below(of: titleTextField)
            .marginTop(metrics.fieldGap)
            .left(metrics.horizontalMargin)
            .right(metrics.horizontalMargin)
            .height(metrics.memoHeight)

        memoPlaceholderLabel.pin
            .top(memoTextView.textContainerInset.top)
            .left(memoTextView.textContainerInset.left + 2)
            .right(memoTextView.textContainerInset.right)
            .sizeToFit(.width)

        let contentHeight = memoTextView.frame.maxY + metrics.fieldGap
        scrollContentView.pin.height(max(contentHeight, scrollView.bounds.height))
        scrollView.contentSize = scrollContentView.frame.size
    }

    private func configureAmountInput() {
        amountTextField.text = ""
        amountTextField.keyboardType = .numberPad
        amountTextField.textColor = .clear
        amountTextField.tintColor = .clear
        amountTextField.alpha = 0.01
        amountTextField.addAction(
            UIAction { [weak self] _ in
                self?.syncAmountSlotText()
            },
            for: .editingChanged
        )

        amountContainerView.onTapped { [weak self] in
            self?.amountTextField.becomeFirstResponder()
        }
    }

    private func configureDateInput() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.timeZone = TimeZone(identifier: "Asia/Seoul")
        datePicker.date = viewModel.selectedDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

        dateTextField.inputView = datePicker
        dateTextField.tintColor = .clear
        dateTextField.text = viewModel.dateText
        styleField(dateTextField)
    }

    private func configureTextInputs() {
        styleField(titleTextField)
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "제목을 입력하세요",
            attributes: [
                .foregroundColor: SDColors.gray80 ?? .lightGray,
                .font: SDFont.pixel(size: 16).font
            ]
        )

        memoTextView.delegate = self
        memoTextView.backgroundColor = SDColors.white100 ?? .white
        memoTextView.layer.cornerRadius = 4
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.borderColor = (SDColors.white300 ?? .systemGray5).cgColor
        memoTextView.font = SDFont.pixel(size: 16).font
        memoTextView.textColor = SDColors.black100 ?? .black
        memoTextView.textContainerInset = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
    }

    private func configureScrollView() {
        scrollView.accessibilityIdentifier = "transactionInput.scrollView"
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        _ = scrollContentView.setBackgroundColor(color: .clear)
    }

    private func configureBackgroundTapGesture() {
        view.addGestureRecognizer(backgroundTapGesture)
    }

    private func styleField(_ textField: PaddedTextField) {
        textField.backgroundColor = SDColors.white100 ?? .white
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor = (SDColors.white300 ?? .systemGray5).cgColor
        textField.font = SDFont.pixel(size: 16).font
        textField.textColor = SDColors.black100 ?? .black
        textField.textInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    }

    private func applyState(animated: Bool) {
        let updates = {
            self.headerView.backgroundColor = self.viewModel.headerColor
            self.amountPrefixLabel.text = self.viewModel.amountPrefixText

            _ = self.ctaButton
                .setBackgroundColor(color: self.viewModel.ctaColor)
                .setText(text: self.viewModel.ctaTitle)

            self.tagButton.isHidden = self.viewModel.isTagButtonHidden
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }

        guard animated else {
            updates()
            return
        }

        UIView.animate(
            withDuration: 0.14,
            delay: 0,
            options: [.curveEaseIn, .beginFromCurrentState]
        ) {
            self.headerView.alpha = 0
            self.ctaButton.alpha = 0
        } completion: { _ in
            updates()
            UIView.animate(
                withDuration: 0.18,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState]
            ) {
                self.headerView.alpha = 1
                self.ctaButton.alpha = 1
            }
        }
    }

    private func handleKeyboard(notification: Notification, isVisible: Bool) {
        let userInfo = notification.userInfo
        let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curveValue = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7
        let frame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let convertedFrame = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - convertedFrame.minY)

        keyboardBottomInset = isVisible ? overlap : 0

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [
                UIView.AnimationOptions(rawValue: curveValue << 16),
                .beginFromCurrentState,
                .allowUserInteraction
            ]
        ) {
            self.setupLayout()
        }
    }

    private func toggleTypeButtonTapped() {
        view.endEditing(true)
        viewModel.toggleType()
        applyState(animated: true)
    }

    @objc private func datePickerValueChanged(_ picker: UIDatePicker) {
        viewModel.updateSelectedDate(picker.date)
    }

    @objc private func backgroundTapped() {
        view.endEditing(true)
    }

    private static func symbolImage(_ name: String) -> UIImage {
        UIImage(systemName: name) ?? UIImage()
    }

    private func syncAmountSlotText() {
        amountSlotView.setText(amountTextField.text)
        view.setNeedsLayout()
    }

    private func applyAmountFontTier(availableWidth: CGFloat, spacing: CGFloat) {
        let nextTier = AmountFontSizer.tier(
            for: amountTextField.text,
            prefix: viewModel.amountPrefixText,
            availableWidth: availableWidth,
            spacing: spacing
        )

        guard nextTier != amountFontTier else {
            return
        }

        amountFontTier = nextTier
        _ = amountPrefixLabel.setFont(font: .pixel(size: nextTier.prefixPointSize))
        _ = amountSlotView.setFont(font: .pixel(size: nextTier.amountPointSize))
        _ = currencyLabel.setFont(font: .pixel(size: nextTier.amountPointSize))
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === backgroundTapGesture else {
            return true
        }

        return touch.view?.isDescendant(ofAny: [UIControl.self, UITextField.self, UITextView.self]) == false
    }
}

private extension UIView {
    func isDescendant(ofAny viewTypes: [UIView.Type]) -> Bool {
        var currentView: UIView? = self

        while let view = currentView {
            if viewTypes.contains(where: { view.isKind(of: $0) }) {
                return true
            }

            currentView = view.superview
        }

        return false
    }
}

private extension TransactionInputVC {

    struct LayoutMetrics {
        let horizontalMargin: CGFloat
        let headerHeight: CGFloat
        let amountHeight: CGFloat
        let amountSpacing: CGFloat
        let headerControlSize: CGFloat
        let headerButtonMargin: CGFloat
        let headerButtonGap: CGFloat
        let formTopMargin: CGFloat
        let fieldHeight: CGFloat
        let fieldGap: CGFloat
        let memoHeight: CGFloat
        let ctaHeight: CGFloat
        let bottomMargin: CGFloat

        init(size: CGSize) {
            horizontalMargin = max(22, size.width * 0.056)
            headerHeight = min(596, max(296, size.height * 0.35))
            amountHeight = max(70, min(96, size.width * 0.12))
            amountSpacing = max(4, size.width * 0.01)
            headerControlSize = max(34, min(68, size.width * 0.086))
            headerButtonMargin = max(10, size.width * 0.025)
            headerButtonGap = max(8, size.width * 0.02)
            formTopMargin = max(36, size.width * 0.09)
            fieldHeight = max(44, min(86, size.width * 0.11))
            fieldGap = max(20, size.width * 0.052)
            memoHeight = max(360, size.height * 0.42)
            ctaHeight = max(54, min(108, size.width * 0.137))
            bottomMargin = max(22, size.width * 0.056)
        }
    }
}

private struct AmountFontTier: Equatable {
    let amountPointSize: Int
    let prefixPointSize: Int
}

private enum AmountFontSizer {

    static let defaultTier = AmountFontTier(
        amountPointSize: 40,
        prefixPointSize: 58
    )

    private static let amountPointSizes = [40, 34, 28, 24]
    private static let prefixPointSizeOffset = 18

    static func tier(
        for rawText: String?,
        prefix: String,
        availableWidth: CGFloat,
        spacing: CGFloat
    ) -> AmountFontTier {
        guard availableWidth > 0 else {
            return defaultTier
        }

        let amountText = formattedAmountText(from: rawText)

        for amountPointSize in amountPointSizes {
            let tier = AmountFontTier(
                amountPointSize: amountPointSize,
                prefixPointSize: amountPointSize + prefixPointSizeOffset
            )

            if amountFitsCentered(
                amountText: amountText,
                prefix: prefix,
                tier: tier,
                availableWidth: availableWidth,
                spacing: spacing
            ) {
                return tier
            }
        }

        let minimumPointSize = amountPointSizes[amountPointSizes.count - 1]

        return AmountFontTier(
            amountPointSize: minimumPointSize,
            prefixPointSize: minimumPointSize + prefixPointSizeOffset
        )
    }

    private static func formattedAmountText(from rawText: String?) -> String {
        guard let rawText else {
            return "0"
        }

        let digits = rawText
            .compactMap(\.wholeNumberValue)
            .map(String.init)
            .joined()

        guard digits.isEmpty == false else {
            return "0"
        }

        let trimmedDigits = digits.drop { $0 == "0" }
        let normalizedDigits = trimmedDigits.isEmpty ? "0" : String(trimmedDigits)

        return normalizedDigits
            .reversed()
            .enumerated()
            .reduce(into: [Character]()) { result, item in
                if item.offset != 0, item.offset.isMultiple(of: 3) {
                    result.append(",")
                }

                result.append(item.element)
            }
            .reversed()
            .map(String.init)
            .joined()
    }

    private static func amountFitsCentered(
        amountText: String,
        prefix: String,
        tier: AmountFontTier,
        availableWidth: CGFloat,
        spacing: CGFloat
    ) -> Bool {
        let amountFont = SDFont.pixel(size: tier.amountPointSize).font
        let prefixFont = SDFont.pixel(size: tier.prefixPointSize).font
        let centerX = availableWidth / 2
        let prefixWidth = textWidth(prefix, font: prefixFont)
        let rightLimit = availableWidth - textWidth("₩", font: amountFont) - spacing
        let amountWidth = slotAmountWidth(amountText, font: amountFont)

        return centerX - amountWidth / 2 - spacing - prefixWidth >= 0
        && centerX + amountWidth / 2 <= rightLimit
    }

    static func centeredAmountWidth(
        for rawText: String?,
        prefix: String,
        tier: AmountFontTier,
        centerX: CGFloat,
        rightLimit: CGFloat,
        spacing: CGFloat
    ) -> CGFloat {
        let amountFont = SDFont.pixel(size: tier.amountPointSize).font
        let prefixFont = SDFont.pixel(size: tier.prefixPointSize).font
        let amountWidth = slotAmountWidth(formattedAmountText(from: rawText), font: amountFont)
        let prefixWidth = textWidth(prefix, font: prefixFont)
        let leftCapacity = centerX - prefixWidth - spacing
        let rightCapacity = rightLimit - centerX
        let centeredMaximumWidth = max(1, min(leftCapacity, rightCapacity) * 2)

        return max(1, min(amountWidth, centeredMaximumWidth))
    }

    private static func slotAmountWidth(_ text: String, font: UIFont) -> CGFloat {
        let digitWidth = textWidth("8", font: font)

        return text.reduce(CGFloat(0)) { width, character in
            if character.isNumber {
                return width + digitWidth
            }

            return width + textWidth(String(character), font: font)
        }
    }

    private static func textWidth(_ text: String, font: UIFont) -> CGFloat {
        ceil((text as NSString).size(withAttributes: [.font: font]).width)
    }
}

private final class PaddedTextField: UITextField {
    var textInsets: UIEdgeInsets = .zero

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
}
