//
//  WaveAnimation.swift
//  SolSol
//
//  Created by NUNU:D on 10/8/25.
//

import UIKit

public struct WaveConfiguration {
    var color: UIColor = .systemBlue
    var amplitude: CGFloat = 10
    var frequency: CGFloat = 1.5
    var hasWaveEffect: Bool = true
    var alpha: CGFloat = 0.8
    
    static let `default` = WaveConfiguration()
    
    static let calm = WaveConfiguration(
        amplitude: 5,
        frequency: 1.0
    )
    
    static let rough = WaveConfiguration(
        amplitude: 15,
        frequency: 2.5
    )
}

public protocol WaveAnimation: UIView {
    var waveLayer: CAShapeLayer { get set }
    var waveConfiguration: WaveConfiguration { get set }
    
    func setupWaveLayer()
    func animateWavte(to percentage: CGFloat, duration: TimeInterval)
    func createWavePath(at height: CGFloat, phase: CGFloat) -> CGPath
}

extension WaveAnimation {
    
    func setupWaveLayer() {
        waveLayer.fillColor = waveConfiguration.color.withAlphaComponent(waveConfiguration.alpha).cgColor
        layer.addSublayer(waveLayer)
    }
    
    func createWavePath(at height: CGFloat, phase: CGFloat = 0) -> CGPath {
        let path = UIBezierPath()
        let width = bounds.width
        
        if waveConfiguration.hasWaveEffect {
            path.move(to: CGPoint(x: 0, y: height))
            
            for x in stride(from: 0, through: width, by: 1) {
                let relativeX = x / width
                let sine = sin(relativeX * .pi * 2 * waveConfiguration.frequency + phase)
                let y = height + sine * waveConfiguration.amplitude
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: width, y: bounds.height))
            path.addLine(to: CGPoint(x: 0, y: bounds.height))
            path.close()
        }
        else {
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: width, y: bounds.height))
            path.addLine(to: CGPoint(x: 0, y: bounds.height))
            path.close()
        }
        
        return path.cgPath
    }
    
    func animateWavte(to percentage: CGFloat, duration: TimeInterval = 2.0) {
        let finalHeight = bounds.height * (1 - percentage)
        let fillAnimation = CABasicAnimation(keyPath: "path")
        
        fillAnimation.duration = duration
        fillAnimation.fromValue = createWavePath(at: bounds.height)
        fillAnimation.toValue = createWavePath(at: finalHeight)
        fillAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fillAnimation.fillMode = .forwards
        fillAnimation.isRemovedOnCompletion = false
        
        waveLayer.add(fillAnimation, forKey: "waterFill")
        
        if waveConfiguration.hasWaveEffect {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.startWaveAnimation(at: finalHeight)
            }
        }
    }
    
    func startWaveAnimation(at height: CGFloat) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1.5
        animation.fromValue = createWavePath(at: height)
        animation.toValue = createWavePath(at: height, phase: .pi * 2)
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        waveLayer.add(animation, forKey: "waveMotion")
    }
    
    func stopWaterAnimation() {
        waveLayer.removeAllAnimations()
    }
}
