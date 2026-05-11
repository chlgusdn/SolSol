//
//  SDCountingLabel.swift
//  SDS
//
//  Created by CareMedi on 5/2/25.
//

import UIKit

public final class SDCountingLabel: UILabel {

    public enum EasingOption {
        case linear
        case easeIn
        case easeOut
        case easeInOut

        func function(_ x: Double) -> Double {
            switch self {
            case .linear:
                return x

            case .easeIn:
                return pow(x, 3)

            case .easeOut:
                return 1 - pow(1 - x, 3)

            case .easeInOut:
                if x < 0.5 {
                    return 4 * pow(x, 3)
                } else {
                    return 1 - pow(-2 * x + 2, 3) / 2
                }
            }
        }
    }

    private var begin: Double = 0.0 {
        didSet {
            amount = end - begin
        }
    }

    private var end: Double = 0.0 {
        didSet {
            amount = end - begin
        }
    }

    private var interval: TimeInterval = 1/60
    private var duration: TimeInterval = 1
    private var amount: Double = 0
    private var startDate: Date!
    private var timer: Timer?
    private var currentTime: Double = 0.0
    private var option: EasingOption = .linear
    private var textForamtter: ((String) -> String)?

    // MARK: public
    public func startAnimation() {
        startDate = Date()
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(updateValue),
            userInfo: nil,
            repeats: true
        )
    }

    // MARK: Private
    @objc
    private func updateValue() {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(startDate)
        let elapsedRate = elapsedTime / duration
        let amount = end - begin
        let currentNumber = option.function(elapsedRate) * amount + begin

        if elapsedTime > duration {
            updateLabel(to: end)
            timer?.invalidate()
            timer = nil
            return
        }

        updateLabel(to: currentNumber)
    }

    private func updateLabel(to number: Double) {
        let intNumber = Int(number)

        if let formatter = self.textForamtter {
            self.text = formatter(intNumber.withComma() ?? "")
        } else {
            self.text = Int(number).withComma() ?? ""
        }
    }

    // MARK: Layout
    public func setFont(font: SDFont) -> Self {
        self.font = font.font
        return self
    }

    @discardableResult
    public func setRange(start: Double = 0.0, end: Double = 0.0) -> Self {
        self.begin = start
        self.end = end
        self.updateLabel(to: start)
        return self
    }

    @discardableResult
    public func setAnimationOption(option: EasingOption) -> Self {
        self.option = option
        return self
    }

    @discardableResult
    public func setTextColor(color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    public func registerTextFormat(textFormat: @escaping (String) -> String) -> Self {
        self.textForamtter = textFormat
        return self
    }

    @discardableResult
    public func setDuration(_ duration: TimeInterval) -> Self {
        self.duration = duration
        return self
    }

    @discardableResult
    public func setInterval(_ interval: TimeInterval) -> Self {
        self.interval = interval
        return self
    }
}

fileprivate extension Int {
    func withComma() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))
    }
}
