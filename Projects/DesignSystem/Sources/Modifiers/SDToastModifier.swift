import SwiftUI

struct SDToastModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if let message {
                Text(message)
                    .font(.sd.callout)
                    .foregroundStyle(DesignSystemAsset.onPrimary.swiftUIColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SDSpacing.l)
                    .padding(.vertical, SDSpacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: SDRadius.m)
                            .fill(.black.opacity(SDOpacity.toast))
                    )
                    .padding(.horizontal, SDSpacing.page)
                    .padding(.bottom, SDSize.toastBottomOffset)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityAddTraits(.isStaticText)
                    .task(id: message) {
                        try? await Task.sleep(for: SDDuration.toast)
                        guard !Task.isCancelled else { return }
                        self.message = nil
                    }
            }
        }
        .animation(.sd.standard, value: message)
    }
}

extension View {
    /// 하단 토스트. `message`가 nil이 아니면 표시되고 2.2초 후 자동으로 nil이 된다
    public func sdToast(_ message: Binding<String?>) -> some View {
        modifier(SDToastModifier(message: message))
    }
}

#Preview {
    @Previewable @State var message: String? = "지출을 저장했어요"
    VStack {
        Button("토스트 띄우기") { message = "지출을 저장했어요" }.buttonStyle(.sdText)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .sdScreen()
    .sdToast($message)
}
