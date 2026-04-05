<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Domain/Entities

## 목적
순수 Swift 도메인 모델 구조체. Domain, Presentation 간에 흐르고 (매퍼를 통해) Data와도 연결되는 타입들입니다. 영속성 어노테이션 없음, UIKit 의존성 없음.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `BaseModel.swift` | 모든 도메인 모델의 기반 프로토콜/구조체 |
| `TransactionModel.swift` | 수입/지출 거래 표현 — `category: CategoryModel` 프로퍼티 포함 |
| `BudgetModel.swift` | 카테고리/기간에 대한 예산 정의 |
| `CategoryModel.swift` | 지출/수입 카테고리 — `categoryName: String` 포함 |
| `NotificationModel.swift` | 알림 레코드 |
| `UserModel.swift` | 사용자 프로필 데이터 |
| `HomeChartSummaryResponseModel.swift` | 홈 차트 집계 응답 — `max: Int`와 `entries: [HomeChartSummaryEntryModel]` 포함 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- 도메인 모델은 값 타입(구조체) — 클래스 상속 없음
- `HomeChartSummaryResponseModel`과 `HomeChartSummaryEntryModel`은 비즈니스 그룹화 로직을 캡슐화하기 때문에 Domain에 위치
- 차트 색상 이름은 `graph{n}00` 규칙 사용 (예: `graph000`, `graph100`) — DesignSystem의 색상 에셋과 일치해야 함

<!-- MANUAL: -->
