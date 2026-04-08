//
//  SDSlotAmountView.swift
//  DesignSystem
//
//  Created by Codex on 4/6/26.
//

import UIKit

public final class SDSlotAmountView: SDView, Layoutable {

    private let stackView = UIStackView()
    private let placeholderLabel = SDLabel()

    private var tokenViews: [UIView] = []
    private weak var boundTextField: UITextField?

    private var textFont: UIFont = SDFont.pixel(size: 20).font
    private var slotTextColor: UIColor = SDColors.black100 ?? .black
    private var slotPlaceholderColor: UIColor = SDColors.gray400 ?? .systemGray
    private var digitSpacing: CGFloat = 0
    private var placeholderText: String = ""
    private var maximumValue: Int?
    private var exceededTextColor: UIColor = SDColors.danger100 ?? .systemRed
    private var renderState = RenderState.empty(placeholderText: "")

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupProperties()
        setupLayout()
        applyRenderState(renderState)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }

    public func setupViews() {
        addSubview(stackView)
        addSubview(placeholderLabel)
    }

    public func setupLayout() {
        let contentWidth = arrangedContentWidth()
        stackView.frame = CGRect(
            x: 0,
            y: 0,
            width: min(contentWidth, bounds.width),
            height: bounds.height
        )
        placeholderLabel.frame = bounds
    }

    public func setupProperties() {
        clipsToBounds = true
        isAccessibilityElement = true

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = digitSpacing

        _ = placeholderLabel
            .setFont(font: .pixel(size: 40))
            .setTextColor(color: slotPlaceholderColor)

        placeholderLabel.textAlignment = .left
        placeholderLabel.adjustsFontSizeToFitWidth = true
        placeholderLabel.minimumScaleFactor = 0.7
    }

    @discardableResult
    public func setPlaceholder(text: String) -> Self {
        placeholderText = text
        _ = placeholderLabel.setText(text: text)

        if renderState.showsPlaceholder {
            renderState = .empty(placeholderText: text)
            applyPlaceholderVisibility(for: renderState)
            accessibilityLabel = renderState.accessibilityLabel
        }

        return self
    }

    @discardableResult
    public func setFont(font: SDFont) -> Self {
        textFont = font.font
        placeholderLabel.font = textFont
        applyFontToTokenViews()

        invalidateIntrinsicContentSize()
        setNeedsLayout()
        return self
    }

    @discardableResult
    public func setTextColor(color: UIColor) -> Self {
        slotTextColor = color
        applyCurrentTextColor()
        return self
    }

    @discardableResult
    public func setPlaceholderColor(color: UIColor) -> Self {
        slotPlaceholderColor = color
        placeholderLabel.textColor = color
        return self
    }

    @discardableResult
    public func setExceededTextColor(color: UIColor) -> Self {
        exceededTextColor = color
        applyCurrentTextColor()
        return self
    }

    @discardableResult
    public func setMaximumValue(_ value: Int?) -> Self {
        maximumValue = value

        let previousState = renderState
        let nextState = makeRenderState(from: renderState.formattedText)
        render(nextState, previousState: previousState)
        renderState = nextState

        return self
    }

    @discardableResult
    public func setSpacing(_ spacing: CGFloat) -> Self {
        digitSpacing = spacing
        stackView.spacing = spacing
        setNeedsLayout()
        return self
    }

    @discardableResult
    public func setText(_ rawText: String?) -> Self {
        update(rawText: rawText)
        return self
    }

    @discardableResult
    public func update(rawText: String?) -> Self {
        let previousState = renderState
        let nextState = makeRenderState(from: rawText)
        render(nextState, previousState: previousState)
        renderState = nextState
        return self
    }

    @discardableResult
    public func bind(to textField: UITextField) -> Self {
        boundTextField?.removeTarget(self, action: #selector(handleBoundTextFieldChange(_:)), for: .editingChanged)
        boundTextField = textField
        textField.addTarget(self, action: #selector(handleBoundTextFieldChange(_:)), for: .editingChanged)
        update(rawText: textField.text)
        return self
    }

    public override var intrinsicContentSize: CGSize {
        let height = ceil(textFont.lineHeight)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    @objc
    private func handleBoundTextFieldChange(_ textField: UITextField) {
        update(rawText: textField.text)
    }

    private func makeRenderState(from rawText: String?) -> RenderState {
        guard let amountText = AmountText(rawText) else {
            return .empty(placeholderText: placeholderText)
        }

        return RenderState(
            formattedText: amountText.formattedText,
            tokens: amountText.tokens,
            validationState: amountText.validationState(maximumValue: maximumValue),
            showsPlaceholder: false,
            accessibilityLabel: amountText.formattedText
        )
    }

    private func render(_ nextState: RenderState, previousState: RenderState) {
        apply(tokens: nextState.tokens, previousTokens: previousState.tokens)
        applyValidationState(nextState.validationState)
        applyPlaceholderVisibility(for: nextState)
        accessibilityLabel = nextState.accessibilityLabel

        if previousState.formattedText != nextState.formattedText,
           nextState.validationState == .exceeded {
            performExceededAnimation()
        }
    }

    private func applyRenderState(_ state: RenderState) {
        apply(tokens: state.tokens, previousTokens: [])
        applyValidationState(state.validationState)
        applyPlaceholderVisibility(for: state)
        accessibilityLabel = state.accessibilityLabel
    }

    private func apply(tokens nextTokens: [Token], previousTokens: [Token]) {
        let alignedPreviousTokens = aligned(tokens: previousTokens, to: nextTokens.count)
        syncViewCount(to: nextTokens.count)

        for index in nextTokens.indices {
            let token = nextTokens[index]
            let oldToken = alignedPreviousTokens[index]

            ensureView(at: index, matches: token)

            switch token {
            case .digit(let value):
                guard let digitView = tokenViews[index] as? SDSlotDigitView else {
                    continue
                }

                digitView.setFont(textFont)
                digitView.setTextColor(activeTextColor(for: renderState.validationState))

                if case .digit(let oldValue) = oldToken, oldValue != value {
                    digitView.setDigit(value, animated: true)
                } else {
                    digitView.setDigit(value, animated: false)
                }
            case .separator(let value):
                guard let separatorView = tokenViews[index] as? SDSlotCharacterView else {
                    continue
                }

                separatorView.setFont(textFont)
                separatorView.setTextColor(activeTextColor(for: renderState.validationState))
                separatorView.setCharacter(value)
            }
        }

        setNeedsLayout()
    }

    private func applyValidationState(_ validationState: SDSlotAmountValidationState) {
        applyCurrentTextColor(for: validationState)
    }

    private func applyPlaceholderVisibility(for state: RenderState) {
        placeholderLabel.isHidden = state.showsPlaceholder == false
        stackView.isHidden = state.showsPlaceholder
    }

    private func applyFontToTokenViews() {
        for view in tokenViews {
            switch view {
            case let digitView as SDSlotDigitView:
                digitView.setFont(textFont)
            case let separatorView as SDSlotCharacterView:
                separatorView.setFont(textFont)
            default:
                break
            }
        }
    }

    private func syncViewCount(to count: Int) {
        if count > tokenViews.count {
            let additional = count - tokenViews.count

            for _ in 0..<additional {
                let placeholderView = UIView(frame: .zero)
                tokenViews.insert(placeholderView, at: 0)
                stackView.insertArrangedSubview(placeholderView, at: 0)
            }
        } else if count < tokenViews.count {
            let removable = tokenViews.count - count

            for _ in 0..<removable {
                guard let view = tokenViews.first else {
                    continue
                }

                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
                tokenViews.removeFirst()
            }
        }
    }

    private func ensureView(at index: Int, matches token: Token) {
        guard index < tokenViews.count else {
            return
        }

        let currentView = tokenViews[index]
        let isMatching: Bool

        switch token {
        case .digit:
            isMatching = currentView is SDSlotDigitView
        case .separator:
            isMatching = currentView is SDSlotCharacterView
        }

        guard isMatching == false else {
            return
        }

        stackView.removeArrangedSubview(currentView)
        currentView.removeFromSuperview()

        let newView = makeView(for: token)
        tokenViews[index] = newView
        stackView.insertArrangedSubview(newView, at: index)
    }

    private func makeView(for token: Token) -> UIView {
        switch token {
        case .digit(let value):
            return SDSlotDigitView(font: textFont, textColor: activeTextColor(for: renderState.validationState), digit: value)
        case .separator(let value):
            return SDSlotCharacterView(font: textFont, textColor: activeTextColor(for: renderState.validationState), character: value)
        }
    }

    private func applyCurrentTextColor() {
        applyCurrentTextColor(for: renderState.validationState)
    }

    private func applyCurrentTextColor(for validationState: SDSlotAmountValidationState) {
        let textColor = activeTextColor(for: validationState)

        for view in tokenViews {
            switch view {
            case let digitView as SDSlotDigitView:
                digitView.setTextColor(textColor)
            case let separatorView as SDSlotCharacterView:
                separatorView.setTextColor(textColor)
            default:
                break
            }
        }
    }

    private func activeTextColor(for validationState: SDSlotAmountValidationState) -> UIColor {
        validationState == .exceeded ? exceededTextColor : slotTextColor
    }

    private func performExceededAnimation() {
        stackView.layer.removeAllAnimations()

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-8, 8, -6, 6, -3, 3, 0]
        animation.duration = 0.24
        animation.timingFunction = CAMediaTimingFunction(name: .linear)

        stackView.layer.add(animation, forKey: "slotAmountExceededShake")
    }

    private func arrangedContentWidth() -> CGFloat {
        guard tokenViews.isEmpty == false else {
            return 0
        }

        let widths = tokenViews.reduce(CGFloat(0)) { partialResult, view in
            partialResult + view.intrinsicContentSize.width
        }

        let spacing = CGFloat(max(tokenViews.count - 1, 0)) * stackView.spacing
        return widths + spacing
    }

    private func aligned(tokens: [Token], to count: Int) -> [Token?] {
        if tokens.count == count {
            return tokens.map(Optional.some)
        }

        if tokens.count < count {
            let prefix = Array<Token?>(repeating: nil, count: count - tokens.count)
            return prefix + tokens.map(Optional.some)
        }

        return Array(tokens.suffix(count)).map(Optional.some)
    }
}


// MARK: - SDSoltDigitView

private final class SDSlotDigitView: SDView, Layoutable {
    private let currentLabel = UILabel()
    private let nextLabel = UILabel()

    private var currentDigit: String
    private var textFont: UIFont
    private var textColorValue: UIColor
    private let animationDuration: TimeInterval = 0.16

    init(font: UIFont, textColor: UIColor, digit: String) {
        self.currentDigit = digit
        self.textFont = font
        self.textColorValue = textColor
        super.init(frame: .zero)
        setupViews()
        setupProperties()
        currentLabel.text = digit
        nextLabel.alpha = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }

    func setupViews() {
        addSubview(currentLabel)
        addSubview(nextLabel)
    }

    func setupLayout() {
        currentLabel.frame = bounds

        let translatedBounds = bounds.offsetBy(dx: 0, dy: bounds.height)
        if nextLabel.layer.animationKeys()?.isEmpty == false || nextLabel.alpha > 0 {
            nextLabel.frame = translatedBounds
        } else {
            nextLabel.frame = bounds
        }
    }

    func setupProperties() {
        clipsToBounds = true
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        currentLabel.textAlignment = .center
        nextLabel.textAlignment = .center
        currentLabel.font = textFont
        nextLabel.font = textFont
        currentLabel.textColor = textColorValue
        nextLabel.textColor = textColorValue
    }

    override var intrinsicContentSize: CGSize {
        let size = ("8" as NSString).size(withAttributes: [.font: textFont])
        return CGSize(width: ceil(size.width), height: ceil(textFont.lineHeight))
    }

    func setFont(_ font: UIFont) {
        textFont = font
        currentLabel.font = font
        nextLabel.font = font
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    func setTextColor(_ color: UIColor) {
        textColorValue = color
        currentLabel.textColor = color
        nextLabel.textColor = color
    }

    func setDigit(_ digit: String, animated: Bool) {
        layoutIfNeeded()
        layer.removeAllAnimations()
        currentLabel.layer.removeAllAnimations()
        nextLabel.layer.removeAllAnimations()

        guard animated, digit != currentDigit else {
            currentDigit = digit
            currentLabel.transform = .identity
            currentLabel.alpha = 1
            currentLabel.text = digit
            nextLabel.transform = .identity
            nextLabel.alpha = 0
            nextLabel.text = digit
            return
        }

        currentDigit = digit
        nextLabel.text = digit
        currentLabel.transform = .identity
        nextLabel.transform = CGAffineTransform(translationX: 0, y: bounds.height)
        nextLabel.alpha = 1

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction]
        ) {
            self.currentLabel.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height)
            self.currentLabel.alpha = 0
            self.nextLabel.transform = .identity
        } completion: { _ in
            self.currentLabel.text = digit
            self.currentLabel.transform = .identity
            self.currentLabel.alpha = 1
            self.nextLabel.alpha = 0
            self.nextLabel.transform = .identity
        }
    }
}

// MARK: - SDSlotCharacterView
private final class SDSlotCharacterView: SDView, Layoutable {
    private let label = UILabel()
    private var textFont: UIFont
    private var textColorValue: UIColor

    init(font: UIFont, textColor: UIColor, character: String) {
        self.textFont = font
        self.textColorValue = textColor
        super.init(frame: .zero)
        setupViews()
        setupProperties()
        label.text = character
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }

    func setupViews() {
        addSubview(label)
    }

    func setupLayout() {
        label.frame = bounds
    }

    func setupProperties() {
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textAlignment = .center
        label.font = textFont
        label.textColor = textColorValue
    }

    override var intrinsicContentSize: CGSize {
        let value = label.text ?? ","
        let size = (value as NSString).size(withAttributes: [.font: textFont])
        return CGSize(width: ceil(size.width), height: ceil(textFont.lineHeight))
    }

    func setFont(_ font: UIFont) {
        textFont = font
        label.font = font
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    func setTextColor(_ color: UIColor) {
        textColorValue = color
        label.textColor = color
    }

    func setCharacter(_ character: String) {
        label.text = character
        invalidateIntrinsicContentSize()
    }
}

// MARK: - Solt Structure
private extension SDSlotAmountView {

    // 현재 슬롯 검증 상태
    enum SDSlotAmountValidationState: Equatable {
        case normal
        case exceeded
    }

    // 토큰 타입
    enum Token: Equatable {
        case digit(String)
        case separator(String)
    }

    struct AmountText {
        let digits: String

        init?(_ rawText: String?) {
            guard let rawText else {
                return nil
            }

            let digits = rawText
                .compactMap(\.wholeNumberValue)
                .map(String.init)
                .joined()

            guard digits.isEmpty == false else {
                return nil
            }

            let trimmed = digits.drop { $0 == "0" }
            self.digits = trimmed.isEmpty ? "0" : String(trimmed)
        }

        var formattedText: String {

            var grouped: [Character] = []
            grouped.reserveCapacity(digits.count + digits.count / 3)

            for (index, character) in digits.reversed().enumerated() {
                if index != 0, index.isMultiple(of: 3) {
                    grouped.append(",")
                }

                grouped.append(character)
            }

            return String(grouped.reversed())
        }

        var tokens: [Token] {
            formattedText.map(Self.token(from:))
        }

        func validationState(maximumValue: Int?) -> SDSlotAmountValidationState {
            guard
                let maximumValue,
                let maximumAmount = AmountText(String(maximumValue))
            else {
                return .normal
            }

            if digits.count != maximumAmount.digits.count {
                return digits.count > maximumAmount.digits.count ? .exceeded : .normal
            }

            return digits > maximumAmount.digits ? .exceeded : .normal
        }

        private static func token(from character: Character) -> Token {
            if character.isNumber {
                return .digit(String(character))
            }

            return .separator(String(character))
        }
    }

    // 렌더링 구조체
    private struct RenderState: Equatable {
        let formattedText: String?
        let tokens: [Token]
        let validationState: SDSlotAmountValidationState
        let showsPlaceholder: Bool
        let accessibilityLabel: String

        static func empty(placeholderText: String) -> Self {
            RenderState(
                formattedText: nil,
                tokens: [],
                validationState: .normal,
                showsPlaceholder: true,
                accessibilityLabel: placeholderText
            )
        }
    }
}
