<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-06 | Updated: 2026-04-06 -->

# Core/Extensions

## 목적
전체 코드베이스에서 사용되는 범용 Swift 타입 확장. 모든 확장은 앱 특화 로직 없는 순수 유틸리티입니다.

## 주요 파일

| 파일 | 설명 |
|------|------|
| `Date+Extension.swift` | 날짜 유틸리티 — `millisecond` 프로퍼티, `daysAgo(_:)`, `subtracting(milliseconds:)`, `startOfDay` 헬퍼 |
| `Decimal+Extension.swift` | Decimal 산술 헬퍼 — `doubleValue` 변환 |
| `Double+Extension.swift` | Double 포맷팅 및 변환 유틸리티 |
| `Int+Extension.swift` | 정수 유틸리티 |
| `LocalizedStringResource+Extension.swift` | 지역화 문자열 접근 편의 기능 |

## AI 에이전트 가이드

### 이 디렉토리에서 작업할 때
- `Date.millisecond`는 밀리초 단위 `TimeInterval` 반환 — DB 시간 범위 쿼리에 일관되게 사용
- `daysAgo(_:)`는 N일 전 날짜 반환 (`HomeViewModel`에서 사용)
- 확장은 최소화 유지 — 기능 특화 헬퍼는 해당 모듈에 위치

<!-- MANUAL: -->
