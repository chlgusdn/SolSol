import ProjectDescription

/// 새 Feature 모듈 생성: `tuist scaffold feature --name Budget`
private let name: Template.Attribute = .required("name")
private let path = "Projects/Features/{{ name }}"

let template = Template(
    description: "TCA Feature 모듈 (Reducer + View + TestStore 테스트)",
    attributes: [name],
    items: [
        .file(path: "\(path)/Project.swift", templatePath: "Project.stencil"),
        .file(path: "\(path)/Sources/{{ name }}Feature.swift", templatePath: "Feature.stencil"),
        .file(path: "\(path)/Sources/{{ name }}View.swift", templatePath: "View.stencil"),
        .file(path: "\(path)/Tests/{{ name }}FeatureTests.swift", templatePath: "Tests.stencil")
    ]
)
