/// 온보딩 슬라이드 (기획서 3.1 — 기록 시작 → 캘린더 → 통계 → 텅장방지)
public enum OnboardingPage: Int, CaseIterable, Equatable, Sendable {
    case welcome
    case calendar
    case statistics
    case budget

    var title: String {
        switch self {
        case .welcome: "쏠쏠한 기록의 시작"
        case .calendar: "한 달이 한눈에 보여요"
        case .statistics: "소비 패턴이 차트로 보여요"
        case .budget: "텅장이 되기 전에 알려드려요"
        }
    }

    var message: String {
        switch self {
        case .welcome: "수입과 지출을 가볍게 기록하고\n나만의 소비 습관을 만들어요"
        case .calendar: "달력에서 날짜별 수입·지출을\n바로 확인할 수 있어요"
        case .statistics: "평균·추세·카테고리별 보고서로\n내 소비를 되돌아봐요"
        case .budget: "예산과 경고 금액을 정해두면\n위험할 때 미리 알려드릴게요"
        }
    }
}
