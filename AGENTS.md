# SolSol — Agent Guide

> 이 파일은 **모든 AI 에이전트의 진입점(오케스트레이터)** 입니다. `CLAUDE.md`, `GEMINI.md` 등 도구별 파일은 이 파일만 가리킵니다.
> 여기에는 "무엇을 어디서 읽고, 어떤 순서로 작업하고, 무엇을 확인하는지"만 둡니다. 세부 규칙은 아래 문서에 있습니다.

## 문서 지도

| 문서 | 내용 | 언제 읽나 |
|------|------|----------|
| `AGENTS.md` | 프로젝트 개요, 구조, 명령어, 작업 절차, Git 규칙(git flow), 완료 체크리스트 | 항상 (가장 먼저) |
| [`RULE.md`](RULE.md) | 코드 규칙 — 모듈 의존성, 파일 생성, 네이밍, Domain / Client / Data / Reducer / Store / 내비게이션 / 동시성 / 시간 / 테스트 | Swift 코드를 작성·수정할 때 |
| [`DESIGN.md`](DESIGN.md) | 디자인 규칙 — 토큰(색상·폰트·간격·라운드·모션), 컴포넌트, 접근성, 문구 | View / DesignSystem을 작성·수정할 때 |

규칙이 문서끼리 충돌하면 **RULE.md → DESIGN.md → AGENTS.md** 순으로 구체적인 문서를 따르고, 충돌 사실을 사용자에게 알린다.

## 프로젝트 개요

SolSol은 수입과 지출을 추적하는 모듈형 iOS 개인 가계부 앱입니다 (iOS 18.0+, iPhone).

| 영역 | 선택 |
|------|------|
| UI | SwiftUI |
| 아키텍처 | TCA(MVI) + Clean Architecture |
| 화면 이동 | TCA `StackState` / `@Presents` |
| 의존성 주입 | swift-dependencies (`@Dependency`, `@DependencyClient`) |
| 데이터베이스 | SQLiteData (GRDB 기반) |
| 동시성 | Swift 6 language mode, Strict Concurrency `complete` |
| 신뢰 시간 (NTP) | Kronos — `@Dependency(\.date)`의 live 값 |
| 테스트 | Swift Testing + TCA `TestStore` |
| 프로젝트 관리 | Tuist 4.209.0 (`mise.toml`로 고정) |

## 디렉토리 구조

```
SolSol/
├── AGENTS.md / RULE.md / DESIGN.md   # 에이전트 문서
├── CLAUDE.md / GEMINI.md             # → AGENTS.md 포인터
├── mise.toml                         # Tuist 버전 고정
├── Tuist.swift / Workspace.swift     # Tuist 설정, 워크스페이스 (App + Projects/**)
├── Tuist/
│   ├── Package.swift / .resolved     # SPM 외부 의존성 (버전 업데이트는 의도적으로만)
│   ├── ProjectDescriptionHelpers/    # Module, ModuleDependency, AppProject 헬퍼
│   └── Templates/                    # tuist scaffold feature / client
├── App/                              # @main, AppFeature(루트 Reducer), AppView
└── Projects/
    ├── Features/<Name>/              # 기능 단위 모듈 — 연관 화면을 함께 둔다 (Home, Budget, …)
    ├── Clients/                      # @DependencyClient 인터페이스 + previewValue
    ├── Data/                         # DAO, liveValue, @Table Record, Mapper, 마이그레이션, Kronos
    ├── Domain/                       # 순수 모델 + 계산 로직
    ├── DesignSystem/                 # 토큰, Style, Modifier, 컴포넌트, 에셋
    └── Core/                         # 공통 확장, 로깅
```

## 아키텍처 한눈에 보기

```
SolSolApp (@main) ── prepareDependencies { $0.bootstrapLive(database:) }
 └── AppView ⇄ Store<AppFeature>
      ├── home: HomeFeature
      ├── path: StackState<Path>        ← push (입력·수정, 지출 리스트, 통계, 텅장방지 …)
      └── toast                         ← 화면이 바뀌어도 보이는 저장 토스트

View ─send(Action)─▶ Reducer ─(State 변경)─▶ View
                        └─ .run ─▶ @Dependency(\.xxxClient) ─▶ Domain 모델

Reducer → Client(Clients) ← liveValue(Data) → DAO → SQLiteData → SQLite
```

의존성 방향 (위반 금지 — 상세는 RULE.md §1):

```
App → Features, Data, Clients, Domain, DesignSystem, Core
Features → Clients, Domain, DesignSystem, Core
Data → Clients, Domain, Core
Clients → Domain
DesignSystem → Core
Domain → Foundation만
```

## 명령어

mise가 활성화되지 않은 셸에서는 앞에 `mise exec --`를 붙인다.

| 목적 | 명령 |
|------|------|
| 의존성 설치 | `tuist install` |
| 프로젝트 생성 | `tuist generate` (파일 추가/삭제, `Project.swift`·헬퍼 수정 후 필수) |
| 전체 테스트 | `tuist test` 또는 `xcodebuild test -workspace SolSol.xcworkspace -scheme SolSol-Workspace -destination 'platform=iOS Simulator,name=<iOS 18+ 기기>' -skipMacroValidation` |
| 모듈 테스트 | `-scheme <Module>` (예: `HomeFeature`, `Data`) |
| 새 Feature | `tuist scaffold feature --name <Name>` |
| 새 Client | `tuist scaffold client --name <Name>` |

## 작업 절차

### 새 Feature 추가
1. `tuist scaffold feature --name Xxx` → `Projects/Features/Xxx` 생성 (Workspace는 `Projects/**` glob이라 수정 불필요)
2. 필요한 Client가 없으면 `tuist scaffold client --name Xxx` → **`bootstrapLive`에 등록** (RULE.md §5)
3. 화면마다 `XxxFeature` / `XxxView` 작성 (RULE.md §2·§6–7, DESIGN.md). 같은 기능의 화면은 한 모듈의 하위 폴더로 둔다
4. `TestStore` 테스트 작성 (RULE.md §10)
5. `App/Project.swift`에 `.feature("Xxx")` 추가, `AppFeature`의 `Path` / `Destination`에 case 추가 + delegate 처리
6. `tuist generate` → 빌드 → 테스트

### 스키마 변경
새 마이그레이션을 추가한다. 기존 마이그레이션은 수정하지 않는다 (RULE.md §4).

## Git 규칙

**git flow** 원칙을 따른다.

### 브랜치
| 브랜치 | 분기 원천 | 머지 대상 | 용도 |
|--------|----------|----------|------|
| `main` | — | — | 배포된 상태만. 직접 커밋 금지. 머지마다 버전 태그(`vX.Y.Z`) |
| `develop` | `main` | — | 다음 배포를 위한 통합 브랜치. 직접 커밋 금지 |
| `feature/<kebab-case>` | `develop` | `develop` | 기능 개발 (예: `feature/transaction-input`) |
| `bugfix/<kebab-case>` | `develop` | `develop` | 배포 전 버그 수정 |
| `release/<X.Y.Z>` | `develop` | `main` + `develop` | 배포 준비 (버전 올리기, 마지막 수정만. 새 기능 금지) |
| `hotfix/<X.Y.Z>` | `main` | `main` + `develop` | 배포된 버전의 긴급 수정 |

- 에이전트는 작업 전 `git status --short --branch`로 현재 브랜치를 확인하고, `main`/`develop`이면 위 표에 맞는 브랜치를 새로 만든다
- 머지된 feature / bugfix / release / hotfix 브랜치는 삭제한다

### 머지 방식

| 방향 | 방식 | 이유 |
|------|------|------|
| `feature/*`, `bugfix/*` → `develop` | **rebase merge** (merge commit 없음) | `develop` 히스토리를 한 줄로 유지 |
| `develop`(또는 `release/*`) → `main` | **merge commit** (`--no-ff`) | 배포 단위를 merge commit 하나로 남김 |
| `hotfix/*` → `main` | **merge commit** (`--no-ff`) | 배포 단위 기록 |
| `release/*`, `hotfix/*` → `develop` (역반영) | **merge commit** (`--no-ff`) | 이미 `main`에 들어간 커밋을 rebase로 복제하지 않기 위해 |

**feature → develop (rebase merge)**
```bash
git switch feature/xxx
git fetch origin
git rebase origin/develop          # 충돌 해결 후 빌드·테스트 통과 확인
git push --force-with-lease        # 본인 feature 브랜치에만 허용
git switch develop
git pull --rebase
git merge --ff-only feature/xxx    # fast-forward만 허용 — 실패하면 rebase부터 다시
git push
```
GitHub PR에서는 **"Rebase and merge"** 를 쓴다.

**develop → main (merge commit)**
```bash
git switch main
git pull
git merge --no-ff develop -m "[release]: vX.Y.Z"
git tag vX.Y.Z
git push && git push --tags
```
GitHub PR에서는 **"Create a merge commit"** 을 쓴다.

- `main`, `develop`은 rebase하거나 force push하지 않는다. 히스토리 재작성은 본인 feature/bugfix 브랜치에서만
- `develop`을 최신화할 때도 `git pull --rebase`로 불필요한 merge commit을 만들지 않는다
- rebase 후에는 반드시 다시 빌드하고 테스트를 통과시킨 뒤 머지한다

### 커밋 메시지
```
[type]: 한국어 요약 (무엇을 왜, 50자 안팎)

(선택) 본문 — 변경 이유, 영향 범위
```

| type | 용도 |
|------|------|
| `feat` | 새 기능, 화면, 모듈 |
| `fix` | 버그 수정 |
| `refactor` | 동작 변화 없는 구조 개선 |
| `test` | 테스트 추가·수정만 |
| `docs` | AGENTS.md / RULE.md / DESIGN.md 등 문서 |
| `chore` | 빌드 설정, 의존성, Tuist, 파일 정리 |
| `release` | `main` 머지 commit, 버전 올리기 (`[release]: v1.2.0`) |
| `hotfix` | 배포 버전 긴급 수정 |

- 예: `[feat]: 거래 수정 화면 push 내비게이션 추가`, `[fix]: 월 이동 시 관찰 스트림 중복 구독 수정`
- 커밋 하나에 논리적 변경 하나. 코드 변경과 그에 맞는 테스트는 같은 커밋에 넣는다
- 커밋 전 완료 체크리스트(아래)를 통과시킨다. 빌드나 테스트가 깨진 상태로 커밋하지 않는다
- 사용자가 요청하기 전에는 커밋·푸시하지 않는다

## 주석
- 코드만 봐서는 알 수 없는 **이유·제약**만 한 줄로 적는다. 코드가 하는 일을 다시 설명하지 않는다
- 여러 줄 배경 설명은 커밋 메시지나 PR 본문에 쓴다

## 절대 하지 말 것
- `Derived/`, `*.xcodeproj`, `*.xcworkspace` 직접 수정 — Tuist가 생성한다
- 의존성 방향 위반 (Feature → Data, Feature → Feature, Domain → 다른 모듈)
- `Date()` / `Date.now` 직접 호출 — `@Dependency(\.date)` 사용
- Combine 사용
- `Package.resolved`의 버전을 의도 없이 올리기
- Tuist 4.209.0 미만 사용 — SPM Package Traits를 무시해 빌드가 깨진다
- `main` / `develop`에 직접 커밋, rebase, force push
- feature → develop을 merge commit으로, develop → main을 rebase/squash로 머지

## 완료 체크리스트
작업을 끝냈다고 보고하기 전에 확인한다.
- [ ] `tuist generate` 후 앱 빌드 성공 (경고 없이 Swift 6 strict concurrency 통과)
- [ ] 전체 테스트 통과 (`SolSol-Workspace` 스킴)
- [ ] 새 Client는 `bootstrapLive`에 등록됨 — 누락 시 앱에서 unimplemented 오류가 난다
- [ ] 새 공개 View/컴포넌트에 `#Preview` 존재
- [ ] TODO / 스텁 / `.skip` 테스트 없음
- [ ] 규칙을 바꿨다면 RULE.md / DESIGN.md를 함께 갱신
