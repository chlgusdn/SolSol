import SwiftUI

extension Font {
    public static var sd: SDFont { SDFont.shared }
}

/// 폰트 토큰 — 디스플레이는 Moneygraphy-Pixel, 본문은 Moneygraphy-Rounded.
/// 모두 Dynamic Type 기준 스타일에 맞춰 크기가 조정된다. 굵기는 하나뿐이므로 `.bold()`로 강조하지 않는다.
public struct SDFont: Sendable {
    static let shared: SDFont = {
        DesignSystemFontFamily.registerAllCustomFonts()
        return SDFont()
    }()

    private static let pixel = DesignSystemFontFamily.머니그라피.pixel.name
    private static let rounded = DesignSystemFontFamily.머니그라피Ttf.rounded.name

    // MARK: 디스플레이 (금액, 제목, 날짜 숫자)
    /// 44 — 입력 금액, 다이얼 D-day
    public let displayHero = Font.custom(pixel, size: 44, relativeTo: .largeTitle)
    /// 36 — 화면 큰 제목, 요약 총액
    public let displayTitle = Font.custom(pixel, size: 36, relativeTo: .largeTitle)
    /// 26 — 인사이트 문구, 월 표시
    public let displayHeadline = Font.custom(pixel, size: 26, relativeTo: .title)
    /// 18 — 카드·리스트 금액, 상단 바 제목
    public let displayBody = Font.custom(pixel, size: 18, relativeTo: .headline)
    /// 14 — 캘린더 날짜·일별 금액
    public let displayCaption = Font.custom(pixel, size: 14, relativeTo: .subheadline)

    // MARK: 본문
    /// 20 — 섹션·시트 제목
    public let title = Font.custom(rounded, size: 20, relativeTo: .title3)
    /// 18 — CTA 버튼, 강조 행
    public let headline = Font.custom(rounded, size: 18, relativeTo: .headline)
    /// 16 — 기본 본문, 입력 필드, 행 제목
    public let body = Font.custom(rounded, size: 16, relativeTo: .body)
    /// 14 — 보조 본문, 칩
    public let callout = Font.custom(rounded, size: 14, relativeTo: .callout)
    /// 12 — 라벨, 날짜 헤더
    public let footnote = Font.custom(rounded, size: 12, relativeTo: .footnote)
    /// 11 — 최소 크기
    public let caption = Font.custom(rounded, size: 11, relativeTo: .caption)
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: SDSpacing.s) {
            Text("12,000원").font(.sd.displayHero)
            Text("통계").font(.sd.displayTitle)
            Text("2025년 1월").font(.sd.displayHeadline)
            Text("-12,000원").font(.sd.displayBody)
            Text("15").font(.sd.displayCaption)
            Text("섹션 제목").font(.sd.title)
            Text("이제부터 시작!").font(.sd.headline)
            Text("제목을 입력해요").font(.sd.body)
            Text("식비").font(.sd.callout)
            Text("2025.01.15 (수)").font(.sd.footnote)
            Text("최소 크기 캡션").font(.sd.caption)
        }
        .padding()
    }
}
