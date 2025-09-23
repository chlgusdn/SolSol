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
                }
                else {
                    return 1 - pow(-2 * x + 2, 3) / 2
                }
            }
        }
    }
    
    private var begin: Double {
        didSet {
            amount = end - begin
        }
    }
    
    private var end: Double {
        didSet {
            amount = end - begin
        }
    }
    
    private let interval: TimeInterval = 1/60
    private let duration: TimeInterval
    private var amount: Double = 0
    private var startDate: Date!
    private var timer: Timer?
    private var currentTime: Double = 0.0
    private let option: EasingOption
    private var textForamtter: ((Double) -> String)?
    
    public init(to begin: Double, from end: Double, duration: TimeInterval = 1, option: EasingOption = .linear) {
        self.begin = begin
        self.end = end
        self.duration = duration
        self.option = option
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: public
    public func startAnimation() {
        startDate = Date()
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
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
            return
        }
        
        updateLabel(to: currentNumber)
    }
    
    private func updateLabel(to number: Double) {
        self.text = "\(Int(number).withComma()!)"
//        if let formatter = self.textForamtter {
//            self.text = formatter(Int(number))
//        }
//        else {
//            self.text = "\(Int(number).withComma()!)"
//        }
    }
    
    //MARK: Layout
    public func setFont(font: SDFont) -> Self {
        self.font = font.font
        return self
    }
    
    public func setTextColor(color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    public func setText(text: String) -> Self {
        self.text = text
        return self
    }
        
    public func registerTextFormat(textFormat: @escaping (Double) -> String) -> Self {
        self.textForamtter = textFormat
        return self
    }
}

fileprivate extension Int {
    func withComma() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))
    }
}
