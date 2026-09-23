import SwiftUI

/// 좌우 흔들림 — `animatableData`가 1 증가할 때마다 한 번 흔든다
struct SDShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    private let amplitude: CGFloat = SDSpacing.s
    private let shakes: CGFloat = 4

    init(trigger: Int) {
        animatableData = CGFloat(trigger)
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amplitude * sin(animatableData * .pi * shakes), y: 0)
        )
    }
}

extension View {
    /// `trigger`가 바뀔 때마다 0.5초간 좌우로 흔든다 (금액 상한 초과 등)
    public func sdShake(trigger: Int) -> some View {
        modifier(SDShakeEffect(trigger: trigger))
            .animation(.sd.shake, value: trigger)
    }
}

#Preview {
    @Previewable @State var count = 0
    VStack(spacing: SDSpacing.l) {
        Text("1,000,000,001원").font(.sd.displayHero).sdShake(trigger: count)
        Button("흔들기") { count += 1 }.buttonStyle(.sdText)
    }
}
