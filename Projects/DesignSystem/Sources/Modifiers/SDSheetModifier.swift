import SwiftUI

struct SDSheetStyleModifier: ViewModifier {
    @State private var contentHeight: CGFloat = 320

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, SDSpacing.page)
            .padding(.top, SDSpacing.xxl)
            .padding(.bottom, SDSpacing.l)
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
            .presentationDetents([.height(contentHeight)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(SDRadius.sheet)
            .presentationBackground(DesignSystemAsset.surface.swiftUIColor)
    }
}

extension View {
    /// 바텀시트 내용에 적용 — 내용 높이 detent, 상단 라운드 24, 드래그 핸들.
    /// TCA의 `.sheet(item: $store.scope(...))` 안에서도 쓴다
    public func sdSheetStyle() -> some View {
        modifier(SDSheetStyleModifier())
    }

    /// `sdSheetStyle`이 적용된 바텀시트
    public func sdSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        sheet(isPresented: isPresented) {
            content().sdSheetStyle()
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    Button("시트 열기") { isPresented = true }
        .buttonStyle(.sdText)
        .sdSheet(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: SDSpacing.l) {
                Text("카테고리 추가").font(.sd.title)
                Text("이름과 색상을 골라요").font(.sd.callout)
                Button("추가하기") { isPresented = false }.buttonStyle(.sdPrimary)
            }
        }
}
