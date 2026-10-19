import ProjectDescription

/// 기존 Feature 모듈에 화면 추가: `tuist scaffold screen --feature Budget --name BudgetSettings`
private let feature: Template.Attribute = .required("feature")
private let name: Template.Attribute = .required("name")
private let path = "Projects/Features/{{ feature }}"

let template = Template(
    description: "기존 Feature 모듈에 화면 추가 (Reducer + View + TestStore 테스트)",
    attributes: [feature, name],
    items: [
        .file(path: "\(path)/Sources/{{ name }}/{{ name }}Feature.swift", templatePath: "../feature/Feature.stencil"),
        .file(path: "\(path)/Sources/{{ name }}/{{ name }}View.swift", templatePath: "../feature/View.stencil"),
        .file(path: "\(path)/Tests/{{ name }}FeatureTests.swift", templatePath: "Tests.stencil")
    ]
)
