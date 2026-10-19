import ProjectDescription

/// 새 Feature 모듈 생성: `tuist scaffold feature --name Budget`
/// 첫 화면은 기능 이름으로 만든다. 화면을 더 넣으려면 `tuist scaffold screen`
private let name: Template.Attribute = .required("name")
private let path = "Projects/Features/{{ name }}"

let template = Template(
    description: "TCA Feature 모듈 (첫 화면 Reducer + View + TestStore 테스트)",
    attributes: [name],
    items: [
        .file(path: "\(path)/Project.swift", templatePath: "Project.stencil"),
        .file(path: "\(path)/Sources/{{ name }}/{{ name }}Feature.swift", templatePath: "Feature.stencil"),
        .file(path: "\(path)/Sources/{{ name }}/{{ name }}View.swift", templatePath: "View.stencil"),
        .file(path: "\(path)/Sources/Support/Domain+Aliases.swift", templatePath: "DomainAliases.stencil"),
        .file(path: "\(path)/Tests/{{ name }}FeatureTests.swift", templatePath: "Tests.stencil")
    ]
)
