import SwiftUI

/// 연속 햅틱 패턴 — 한 번으로 약한 알림(텅장방지 경고·위험)을 강하게 전달한다
public struct SDHapticPattern: Equatable, Sendable {
    let steps: [SensoryFeedback]

    public init(_ steps: [SensoryFeedback]) {
        self.steps = steps
    }

    /// 경고: 경고음 + 강한 진동 2번
    public static let warning = SDHapticPattern([.warning, .impact(weight: .heavy), .impact(weight: .heavy)])
    /// 위험·초과: 오류음 + 강한 진동 3번
    public static let danger = SDHapticPattern([.error, .impact(weight: .heavy), .impact(weight: .heavy), .impact(weight: .heavy)])

    /// 진동 사이 간격 — 짧으면 하나로 뭉개진다
    static let interval: Duration = .milliseconds(140)
}

struct SDHapticPatternModifier<Trigger: Equatable>: ViewModifier {
    let pattern: SDHapticPattern?
    let trigger: Trigger
    @State private var step = 0
    @State private var feedback: SensoryFeedback?

    func body(content: Content) -> some View {
        content
            .sensoryFeedback(trigger: step) { _, _ in feedback }
            .onChange(of: trigger) {
                guard let pattern else { return }
                Task {
                    for next in pattern.steps {
                        feedback = next
                        step += 1
                        try? await Task.sleep(for: SDHapticPattern.interval)
                    }
                }
            }
    }
}

extension View {
    /// `trigger`가 바뀔 때마다 `pattern`을 순서대로 울린다. `.sensoryFeedback`은 한 번만 울려서 연속 알림에 쓴다
    public func sdHapticPattern(_ pattern: SDHapticPattern?, trigger: some Equatable) -> some View {
        modifier(SDHapticPatternModifier(pattern: pattern, trigger: trigger))
    }
}

#Preview {
    @Previewable @State var count = 0
    Button("위험 패턴") { count += 1 }
        .buttonStyle(.sdPrimaryCompact)
        .sdHapticPattern(.danger, trigger: count)
}
