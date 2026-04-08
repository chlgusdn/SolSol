import Testing
import UIKit
@testable import DesignSystem

struct DesignSystemTests {
    
    @Test
    @MainActor
    func 슬롯_금액_뷰는_플레이스홀더와_포맷된_금액에_맞춰_접근성_라벨을_갱신한다() async throws {
        let view = makeSlotAmountView()
            .setPlaceholder(text: "금액을 입력해주세요")

        #expect(view.accessibilityLabel == "금액을 입력해주세요")

        _ = view.setText("001230")

        #expect(view.accessibilityLabel == "1,230")

        _ = view.setText(nil)

        #expect(view.accessibilityLabel == "금액을 입력해주세요")
    }

    @Test
    @MainActor
    func 슬롯_금액_뷰는_숫자가_아닌_문자를_무시하고_금액을_포맷한다() async throws {
        let view = makeSlotAmountView()

        _ = view.setText("12,34원")
        view.layoutIfNeeded()

        #expect(displayedTokenTexts(in: view) == ["1", ",", "2", "3", "4"])
    }

    @Test
    @MainActor
    func 슬롯_금액_뷰는_0으로만_구성된_입력을_하나의_0으로_정규화한다() async throws {
        let view = makeSlotAmountView()

        _ = view.setText("000")
        view.layoutIfNeeded()

        #expect(displayedTokenTexts(in: view) == ["0"])
        #expect(view.accessibilityLabel == "0")
    }

    @Test
    @MainActor
    func 슬롯_금액_뷰는_최대값이_변경되면_검증_상태를_다시_적용한다() async throws {
        let view = makeSlotAmountView()
            .setTextColor(color: .blue)
            .setExceededTextColor(color: .red)
            .setText("1001")

        #expect(displayedTokenColors(in: view).allSatisfy { $0 == UIColor.blue })

        _ = view.setMaximumValue(1_000)
        view.layoutIfNeeded()

        #expect(displayedTokenColors(in: view).allSatisfy { $0 == UIColor.red })
    }

    @Test
    @MainActor
    func 슬롯_금액_뷰는_텍스트필드와_바인딩되면_초기_값을_즉시_반영한다() async throws {
        let textField = UITextField(frame: .zero)
        textField.text = "9999"

        let view = makeSlotAmountView()
            .bind(to: textField)

        view.layoutIfNeeded()

        #expect(view.accessibilityLabel == "9,999")
        #expect(displayedTokenTexts(in: view) == ["9", ",", "9", "9", "9"])
    }
}

@MainActor
private func makeSlotAmountView() -> SDSlotAmountView {
    let view = SDSlotAmountView(frame: CGRect(x: 0, y: 0, width: 320, height: 56))
    view.layoutIfNeeded()
    return view
}

private func displayedTokenTexts(in view: SDSlotAmountView) -> [String] {
    guard let stackView = view.subviews.compactMap({ $0 as? UIStackView }).first else {
        return []
    }

    return stackView.arrangedSubviews.compactMap { arrangedSubview in
        visibleLabels(in: arrangedSubview).first?.text
    }
}

private func displayedTokenColors(in view: SDSlotAmountView) -> [UIColor] {
    guard let stackView = view.subviews.compactMap({ $0 as? UIStackView }).first else {
        return []
    }

    return stackView.arrangedSubviews.compactMap { arrangedSubview in
        visibleLabels(in: arrangedSubview).first?.textColor
    }
}

private func visibleLabels(in view: UIView) -> [UILabel] {
    let nestedLabels = view.subviews.flatMap(visibleLabels(in:))
    let currentLabel = (view as? UILabel).map { [$0] } ?? []

    return (currentLabel + nestedLabels).filter { $0.alpha > 0.01 && $0.isHidden == false }
}
