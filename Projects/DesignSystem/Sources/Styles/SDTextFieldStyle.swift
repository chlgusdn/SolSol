import SwiftUI

/// 기본 텍스트필드 스타일
public struct SDTextFieldStyle: TextFieldStyle {
    public init() {}

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.sd.body)
            .padding(SDSpacing.m)
            .background(
                RoundedRectangle(cornerRadius: SDRadius.s)
                    .fill(DesignSystemAsset.background.swiftUIColor)
            )
    }
}

extension TextFieldStyle where Self == SDTextFieldStyle {
    public static var sd: SDTextFieldStyle { SDTextFieldStyle() }
}

#Preview {
    TextField("메모", text: .constant(""))
        .textFieldStyle(.sd)
        .padding()
}
